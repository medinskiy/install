#!/usr/bin/env sh

echo "${WHITE} Проверка установки Apache\c${BREAK}"
sleep 1 & spinner

if which apache2 > /dev/null; then
    echo "${OK}"
else

    echo "\n${RED} Apache2 не найден!${FAIL}"
    echo "${YELLOW} Установить (Y/n) ${BREAK}\c"
    read item

    if [ "${item}" = "y" -o "${item}" = "Y" -o "${item}" = "" ]; then

        if ! apt-cache pkgnames | grep ^apache2$ > /dev/null; then
            echo "${RED} Apache2 пакет не найден. Добавте репозиторий ${FAIL}"
        else
            echo "${WHITE} Установка Apache2\c${BREAK}"
            sudo apt-get install apache2 -y >> install.log & spinner
            echo "${OK}"

            if ! which apache2 > /dev/null; then
                echo "${RED} Apache не удалось установить! ${FAIL}"
            fi
        fi

    else
        echo "${RED} Apache не будет установлен! ${FAIL}"
    fi
fi
