#!/usr/bin/env sh

cert() {
    if [ $# -eq 0 ]; then return 1; fi;
    local DOMAIN="$1"
    # Generate a passphrase
    export PASSPHRASE=$(head -c 500 /dev/urandom | tr -dc a-z0-9A-Z | head -c 128; echo)
    # Certificate details; replace items in angle brackets with your own info
    local subj="
C=US
ST=OR
O=Blah
localityName=Portland
commonName=${DOMAIN}
organizationalUnitName=IT
emailAddress=webmaster@${DOMAIN}
"
    # Generate the server private key
    openssl genrsa -des3 -out ${DOMAIN}.key -passout env:PASSPHRASE 2048
    # Generate the CSR
    openssl req \
        -new \
        -batch \
        -subj "$(echo -n "$subj" | tr "\n" "/")" \
        -key ${DOMAIN}.key \
        -out ${DOMAIN}.csr \
        -passin env:PASSPHRASE
    cp ${DOMAIN}.key ${DOMAIN}.key.org
    # Strip the password so we don't have to type it every time we restart Apache
    openssl rsa -in ${DOMAIN}.key.org -out ${DOMAIN}.key -passin env:PASSPHRASE
    # Generate the cert (good for 10 years)
    openssl x509 -req -days 3650 -in ${DOMAIN}.csr -signkey ${DOMAIN}.key -out ${DOMAIN}.crt

    return 0
}

createpath() {
    if [ $# -eq 0 ]; then return 1; fi;
    if [ -d $1 ]; then
        echo "${RED} Directory $1 exist ${BREAK}"
    else
        sudo mkdir -p $1
        echo "${CYAN} Directory $1 was created ${BREAK}"
    fi
}

echo "${YELLOW} Добавить домен: ${BREAK}\c"
read SITE_NAME
if [ ! ${SITE_NAME} ]; then return 1; fi;


cd "${DIR}/.."
ROOT_DIR=`pwd`
cd ${DIR}
SITE_ROOT="/var/www/${SITE_NAME}"
WEB_DIR="${SITE_ROOT}/www"
LOG_DIR="${SITE_ROOT}/log"
CONF_DIR="${ROOT_DIR}/config"


echo "${WHITE} Creating paths${BREAK}"
createpath "${SITE_ROOT}"
createpath "${ROOT_DIR}/www"
createpath "${ROOT_DIR}/log"
createpath "${CONF_DIR}"


echo "${WHITE} Link paths\c${BREAK}"
if [ -h ${WEB_DIR} -o -f ${WEB_DIR} ]; then sudo rm -rf ${WEB_DIR}; fi
if [ -h ${LOG_DIR} -o -f ${LOG_DIR} ]; then sudo rm -rf ${LOG_DIR}; fi

sudo ln -s "${ROOT_DIR}/www" "${WEB_DIR}"
sudo ln -s "${ROOT_DIR}/log" "${LOG_DIR}"
echo "${OK}"


echo "${WHITE} Set permissions\c${BREAK}"
sudo chown ruslan:ruslan -R ${SITE_ROOT}
sudo chmod 0755 -R ${WEB_DIR}
sudo chmod 0777 -R ${LOG_DIR}
sudo chmod 0777 -R ${CONF_DIR}
echo "${OK}"


echo "${WHITE} Creating Virtual Host\c${BREAK}"
if [ -f "${CONF_DIR}/${SITE_NAME}.conf" ]; then sudo rm "${CONF_DIR}/${SITE_NAME}.conf"; fi
sudo cat <<EOF >> "${CONF_DIR}/${SITE_NAME}.conf"
ServerAdmin webmaster@${SITE_NAME}
DocumentRoot ${WEB_DIR}
ErrorLog ${LOG_DIR}/error.log
CustomLog ${LOG_DIR}/access.log combined

<Directory ${WEB_DIR}>
    Options Indexes FollowSymLinks MultiViews
    AllowOverride All
    Order allow,deny
    allow from all
</Directory>

<VirtualHost *:80>
    ServerName ${SITE_NAME}
    ServerAlias www.${SITE_NAME}
    Redirect permanent / https://${SITE_NAME}/
</VirtualHost>

<IfModule mod_ssl.c>
	<VirtualHost *:443>
		SSLEngine on

        ServerName ${SITE_NAME}
        ServerAlias www.${SITE_NAME}

		SSLCertificateFile ${CONF_DIR}/${SITE_NAME}.crt
		SSLCertificateKeyFile ${CONF_DIR}/${SITE_NAME}.key

		<FilesMatch "\.(cgi|shtml|phtml|php)$">
			SSLOptions +StdEnvVars
		</FilesMatch>
		<Directory /usr/lib/cgi-bin>
			SSLOptions +StdEnvVars
		</Directory>

	</VirtualHost>
</IfModule>
EOF
echo "${OK}"


echo "${WHITE} Link configs\c${BREAK}"
if [ -h "/etc/apache2/sites-available/${SITE_NAME}.conf" -o -f "/etc/apache2/sites-available/${SITE_NAME}.conf" ]; then
    sudo rm "/etc/apache2/sites-available/${SITE_NAME}.conf"
fi
if [ -h "/etc/apache2/sites-enabled/${SITE_NAME}.conf" -o -f "/etc/apache2/sites-enabled/${SITE_NAME}.conf" ]; then
    sudo rm "/etc/apache2/sites-enabled/${SITE_NAME}.conf"
fi
sudo ln -s "${CONF_DIR}/${SITE_NAME}.conf" "/etc/apache2/sites-available/${SITE_NAME}.conf"
sudo ln -s "${CONF_DIR}/${SITE_NAME}.conf" "/etc/apache2/sites-enabled/${SITE_NAME}.conf"
echo "${OK}"


echo "${WHITE} Generate Cert\c${BREAK}"
cd ${CONF_DIR}
cert ${SITE_NAME} 2>/dev/null && echo "${OK}" || echo "${FAIL}"
cd ${DIR}


echo "${WHITE} Editing /etc/hosts\c${BREAK}"
sudo cat <<EOF >> "/etc/hosts"
127.0.0.1   ${SITE_NAME}
EOF
echo "${OK}"


echo "${WHITE} Create index file\c${BREAK}"
cat <<EOF >> "${WEB_DIR}/index.html"
<!DOCTYPE html>
<html>
  <head>
    <title>${SITE_NAME}</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
  </head>
  <body>
	<h1>Site ${SITE_NAME} works</h1>
  </body>
</html>
EOF
echo "${OK}"


echo "${WHITE} Restarting Apache2\c${BREAK}"
sudo a2enmod ssl >> /dev/null
sudo service apache2 restart
echo "${OK}"



echo "${CYAN} Finished! ${BREAK}"
echo "${CYAN} Web address: https://${SITE_NAME} ${BREAK}"
