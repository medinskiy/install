
# text color
BLACK='\033[30m'        #  ${BLACK}
RED='\033[31m'          #  ${RED}
GREEN='\033[32m'        #  ${GREEN}
YELLOW='\033[33m'       #  ${YELLOW}
BLUE='\033[34m'         #  ${BLUE}
MAGENTA='\033[35m'      #  ${MAGENTA}
CYAN='\033[36m'         #  ${CYAN}
GRAY='\033[37m'         #  ${GRAY}
WHITE='\033[37m'        #  ${WHITE}

# background colors
BGBLACK='\033[40m'      #  ${BGBLACK}
BGRED='\033[41m'        #  ${BGRED}
BGGREEN='\033[42m'      #  ${BGGREEN}
BGBROWN='\033[43m'      #  ${BGBROWN}
BGBLUE='\033[44m'       #  ${BGBLUE}
BGMAGENTA='\033[45m'    #  ${BGMAGENTA}
BGCYAN='\033[46m'       #  ${BGCYAN}
BGGRAY='\033[47m'       #  ${BGGRAY}
BGDEF='\033[49m'        #  ${BGDEF}

#######
BREAK='\033[m'          #  ${BREAK}

if [ $(tput cols) -gt 80 ]; then COLS=80; else COLS=$(tput cols); fi;
TOEND=$(tput hpa ${COLS})$(tput cub 10)
FAIL="${BREAK}${BGRED}${BLACK}${TOEND} [FAIL] ${BREAK}"
OK="${BREAK}${BGGREEN}${BLACK}${TOEND}  [OK]  ${BREAK}"