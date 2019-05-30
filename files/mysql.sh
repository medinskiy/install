#!/usr/bin/env bash

mysqluser(){
    if [ $# -eq 0 ]; then echo "${FAIL}" && return 0; fi;

    local rootpasswd=$1
    local user="";
    local password="";
    local k=0;

    while [ "${user}" = "" -a ${k} != 3 ]; do
        echo "\n${YELLOW} MySQL user: ${BREAK}\c"
        read user
        k=$(($k+1))
    done
    k=0
    while [ "${password}" = "" -a ${k} != 3 ]; do
        echo "${YELLOW} Password: ${BREAK}\c"
        read password
        k=$(($k+1))
    done

    if [ "${user}" = "" -o "${password}" = "" ]; then echo "${FAIL}" && return 0; fi;

    echo "${WHITE} Создание пользователя\c${BREAK}"
    sudo mysql -uroot -p${rootpasswd} -e "CREATE USER '${user}'@'localhost' IDENTIFIED BY '${password}';" 2> /dev/null
    sudo mysql -uroot -p${rootpasswd} -e "GRANT ALL PRIVILEGES ON *.* TO '${user}'@'localhost';" 2> /dev/null
    sudo mysql -uroot -p${rootpasswd} -e "FLUSH PRIVILEGES;" 2> /dev/null

    echo "${OK}"
}

echo "${WHITE} Проверка установки MySQL\c${BREAK}"
sleep 1 & spinner

if which mysql > /dev/null; then
    echo "${OK}"
else

    echo "\n${RED} MySQL не найден!${FAIL}"
    echo "${YELLOW} Установить (Y/n) ${BREAK}\c"
    read item

    if [ "${item}" = "y" -o "${item}" = "Y" -o "${item}" = "" ]; then

        if ! apt-cache pkgnames | grep ^mysql-server$ > /dev/null; then
            echo "${RED} MySQL пакет не найден. Добавте репозиторий ${FAIL}"
        else
            echo "${WHITE} Установка MySQL\c${BREAK}"
            sudo DEBIAN_FRONTEND=noninteractive apt-get install mysql-server -y >> install.log & spinner
            echo "${OK}"

            if ! which mysql > /dev/null; then
                echo "${RED} MySQL не удалось установить! ${FAIL}"
            else

                echo "${YELLOW} MySQL root password: ${BREAK}\c"
                read rootpasswd
                sudo mysql -Bse "ALTER USER 'root'@'localhost' IDENTIFIED BY '${rootpasswd}'" -uroot mysql  >> install.log
                echo "${CYAN} Для пользователя 'root' установлен пароль '${rootpasswd}'. ${BREAK}"

                echo "${YELLOW} Создание пользователя ${BREAK}\c"
                mysqluser ${rootpasswd}
            fi
        fi

    else
        echo "${RED} MySQL  не будет установлен! ${FAIL}"
    fi
fi
