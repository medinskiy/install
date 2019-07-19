#!/usr/bin/env sh

RELEASE=$(lsb_release -sc)
DIR="$( cd "$( dirname "$0" )" && pwd )"
. "${DIR}/files/add.sh"

spinner(){
    local pid=$!
    local delay=0.5
    while [ "$(ps a | awk '{print $1}' | grep ${pid})" ]; do
        echo ".\c"
        sleep ${delay}
    done
}

update(){
	echo "${WHITE}  Обновление репозиториев\c${BREAK}"
	sudo apt-get update -y >> /dev/null & spinner
	echo "${OK}"
	echo "${WHITE}  Установка пакетов\c${BREAK}"
	sudo apt-get upgrade -y >> /dev/null & spinner
	echo "${OK}"
}

addrepo(){
	echo "${YELLOW} Добавить репозиторий: ${BREAK}\c"
    read repo
    if [ "$repo" != "" ]; then
    	echo "${WHITE} Добавляю \c${BREAK}"
        sudo add-apt-repository "$repo" >> install.log & spinner
        echo "${OK}"
    fi
}

if [ ${RELEASE} -lt '16' ]; then
    echo "$RED Минимальная версия для установки - Ubuntu 16.04 $BREAK\c"
    echo "$FAIL"
    exit
fi

clear
while true; do
	clear
	echo "1) Update packages"
	echo "2) Add Repo"
	echo "3) Install Apache"
	echo "4) Install NodeJS"
	echo "5) Install MySQL"
	echo "6) Install PHP"
	echo "7) Add Host"
	echo "8) Exit"

	read -p "Select: " command
	case "${command}" in
		1 ) clear && update                     && echo "Press Enter \c" && read i;;
		2 ) clear && addrepo && update          && echo "Press Enter \c" && read i;;
		3 ) clear && . "${DIR}/files/apache.sh" && echo "Press Enter \c" && read i;;
		4 ) clear && . "${DIR}/files/node.sh"   && echo "Press Enter \c" && read i;;
		5 ) clear && . "${DIR}/files/mysql.sh"  && echo "Press Enter \c" && read i;;
		6 ) clear && . "${DIR}/files/php.sh"    && echo "Press Enter \c" && read i;;
		7 ) clear && . "${DIR}/files/vhosts.sh" && echo "Press Enter \c" && read i;;
		8 ) break;;
	esac
done
