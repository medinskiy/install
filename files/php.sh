#!/usr/bin/env sh

composerInstall(){
    local EXPECTED_SIGNATURE="$(wget -q -O - https://composer.github.io/installer.sig)"
    sudo php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    local ACTUAL_SIGNATURE="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

    if [ "${EXPECTED_SIGNATURE}" != "${ACTUAL_SIGNATURE}" ]; then
        echo "\n${RED} Invalid installer signature! ${FAIL}"
        sudo rm composer-setup.php
    else
        php composer-setup.php --quiet
        sudo rm composer-setup.php
        sudo mv composer.phar /usr/local/bin/composer
        echo "${OK}"
    fi
}

echo "${WHITE} Проверка установки PHP7.2\c${BREAK}"
sleep 1 & spinner

pkgs="bz2 common cgi cli bcmath mysql sqlite3 json opcache sybase curl xml xsl intl zip mbstring readline gd xmlrpc"

if which php > /dev/null; then
    echo "${OK}"
else

    echo "\n${RED} PHP7.2 не найден!${FAIL}"
    echo "${YELLOW} Установить (Y/n) ${BREAK}\c"
    read item

    if [ "${item}" = "y" -o "${item}" = "Y" -o "${item}" = "" ]; then

        if ! apt-cache pkgnames | grep ^php7.2 > /dev/null; then
            echo "${RED} PHP7.2 пакет не найден. Добавте репозиторий ${FAIL}"
        else
            echo "${WHITE} Установка PHP7.2\c${BREAK}"
            sudo apt-get install php7.2 libapache2-mod-php7.2 -y >> install.log & spinner
            echo "${OK}"
            if ! which php > /dev/null; then
                echo "${RED} PHP7.2 не удалось установить! ${FAIL}"
            fi

            for pkg in ${pkgs}
            do
                echo "${WHITE} Установка пакета php7.2-${pkg}\c${BREAK}"
                sudo apt-get install php7.2-"${pkg}" -y >> install.log & spinner
                echo "${OK}"
            done

            echo "${WHITE} Перезапуск Apache2\c${BREAK}"
            sudo service apache2 reload >> install.log & spinner
            echo "${OK}"

            echo "${WHITE} Установка Сomposer\c${BREAK}"
            composerInstall
        fi

    else
        echo "${RED} PHP7.2 не будет установлен! ${FAIL}"
    fi
fi
