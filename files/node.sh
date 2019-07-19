#!/usr/bin/env sh

echo "${WHITE} Проверка установки NodeJS\c${BREAK}"
sleep 1 & spinner

if which node > /dev/null; then
    echo "${OK}"
else

    echo "\n${RED} NodeJS не найден!${FAIL}"
    echo "${YELLOW} Установить (Y/n) ${BREAK}\c"
    read item

    if [ "${item}" = "y" -o "${item}" = "Y" -o "${item}" = "" ]; then

        echo "${WHITE} Добавляю репозиторий\c${BREAK}"
        curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash - >> install.log & spinner
        echo "${OK}"

        echo "${WHITE} Установка NodeJS\c${BREAK}"
        sudo apt-get install nodejs -y >> install.log & spinner
        echo "${OK}"

        if ! which node > /dev/null; then
            echo "${RED} NodeJS не удалось установить! ${FAIL}"
        fi

    else
        echo "${RED} NodeJS не будет установлен! ${FAIL}"
    fi
fi
