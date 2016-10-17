#!/bin/bash

# Colours <3
RED='\033[0;31m'
GREEN='\033[0;32m'
BOLD=$(tput bold)
RESET=$(tput sgr0)

# Function to show the script's usage
function usage
{
    printf "Usage: ./tconv.sh -m atoh -i some_text"
    printf "\n\t-m, --mode\tMode, available modes:
                            rev  (Reverse Endianness)
                            atoh (ASCII to Hex)
                            atod (ASCII to Decimal)
                            dtoa (Decimal to ASCII)
                            dtoh (Decimal to Hex)
                            htoa (Hex to ASCII)
                            htod (Hex to Decimal)
                            atoA (ASCII to All; hex and decimal)
                            dtoA (Decimal to All; ASCII and hex)
                            htoA (Hex to All; ASCII and decimal)"
    printf "\n\t-i, --input\tThe ASCII/decimal/hex value you want to convert"
    printf "\n\t-h, --help\tShow help and exit\n"
    printf "\nTo read from a file, use: ./tconv.sh -m atoh -i \"\$(cat test.txt)\"\n"
}

while [ "$1" != "" ]; do
    case $1 in
        -m | --mode )           shift
                                mode=$1
                                ;;
        -i | --input )          shift
                                input=$1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

# Function to reverse the Endianness of the input
function rev
{
    input=$(echo ${input} | sed 's/0x//')
    printf "${BOLD}Input:\n\t${GREEN}${BOLD}0x${input}${RESET}\n"
    printf "${BOLD}Payload:${RESET}\n\t"
    result0=$(echo ${input} | grep -o .. | sed 's/^/&\\x/g' | echo "$(tr -d '\n')")
    echo -en "${GREEN}${BOLD}"; echo -n ${result0}; echo -e "${RESET}"

    result1=$(echo ${input} | grep -o .. | tac | echo "$(tr -d '\n')")
    result2=$(echo ${input} | grep -o .. | tac | sed 's/^/&\\x/g' | echo "$(tr -d '\n')")
    printf "\n${BOLD}Reversed Input:${RESET}\n\t"
    echo -e "${RED}${BOLD}0x${result1}${RESET}"
    printf "${BOLD}Reversed Payload:${RESET}\n"
    echo -en "\t${RED}${BOLD}"; echo -n ${result2}; echo -e "${RESET}"
}

# ASCII to All
function atoA
{
    printf "\n${BOLD}ASCII:${RESET}\n${GREEN}${BOLD}${input}${RESET}\n"
    printf "\n${BOLD}Decimal:${RESET}\n"
    atod
    printf "\n${BOLD}Hex:${RESET}\n"
    atoh
}

# Decimal to All
function dtoA
{
    printf "\n${BOLD}Decimal:${RESET}\n${GREEN}${BOLD}${input}${RESET}\n"
    printf "\n${BOLD}ASCII:${RESET}\n"
    dtoa
    printf "\n${BOLD}Hex:${RESET}\n"
    dtoh
}

# Hex to All
function htoA
{
    printf "\n${BOLD}Hex:${RESET}\n${GREEN}${BOLD}${input}${RESET}\n"
    printf "\n${BOLD}ASCII:${RESET}\n"
    htoa
    printf "\n${BOLD}Decimal:${RESET}\n"
    htod
}

# ASCII to Decimal Conversion
function atod
{
    result=$(python -c "for i in \"${input}\": print ord(i)")
    echo -e ${RED}${BOLD}${result}${RESET}
}

# ASCII to Hex Conversion
function atoh
{
    result=$(xxd -p <<< "${input}" | tr -d \\n)
    echo -e ${RED}${BOLD}${result:0:${#result}-2}${RESET}
}

# Decimal to ASCII Conversion
function dtoa
{
    # I need to fix the spaces here!
    for n in ${input}
    do
        # Check if the input is a number
        if [ $n -eq $n 2>/dev/null ]; then
            # Check if the input can be converted to ASCII range 0-255
            if [[ $n -gt 255 ]] || [[ $n -lt 0 ]]; then
                check="failedRange"
            fi
        else
            check="failedType"
        fi
    done

    if [[ ${check} == "failedRange" ]]; then
        echo "The provided input contains reference(s) to non-ASCII characters."
    elif [[ ${check} == "failedType" ]]; then
        echo "The provided input contains non-Decimal characters."
    else
        result=$(python -c "for i in \"${input}\".split(): print chr(int(i))")
        echo -e ${RED}${BOLD}${result}${RESET}
    fi
}

# Decimal to Hex Conversion
function dtoh
{
    for n in ${input}
    do
        if [ $n -ne $n 2>/dev/null ]; then
            check="failedType"
        fi
    done

    if [[ ${check} == "failedType" ]]; then
        echo "The provided input contains non-Decimal characters."
    else
        result=$(python -c "for i in \"${input}\".split(): print hex(int(i))" | sed 's/0x//g')
        echo -e ${RED}${BOLD}${result}${RESET}
    fi
}

# Hex to ASCII Conversion
function htoa
{
    if [[ $(printf "${input}" | cut -c1-2) != "0x" ]]; then
    	input=$(printf "0x${input}")
    fi
    result=$(xxd -r -p <<< ${input})
    echo -e ${RED}${BOLD}${result}${RESET}
}

# Hex to Decimal Conversion
function htod
{
    input=$(echo -n ${input} | sed 's/0x//g')

    for n in ${input}
    do
        if [[ ${n} =~ ^[A-Fa-f0-9]*$ ]]; then
            # ok
            check="ok"
        else
            check="failedType"
        fi
    done

    if [[ ${check} == "failedType" ]]; then
        echo "The provided input contains non-hexadecimal characters."
    else
        result=$(python -c "for i in \"${input}\".split(): print int(\"0x\"+i, 0),;")
        echo -e ${RED}${BOLD}${result}${RESET}
    fi
}

# Modes
Modes[0]='rev'
Modes[1]='atoh'
Modes[2]='atod'
Modes[3]='dtoa'
Modes[4]='dtoh'
Modes[5]='htoa'
Modes[6]='htod'
Modes[7]='atoA'
Modes[8]='dtoA'
Modes[9]='htoA'


# Check if an implemented mode has been provided
match=0
for mod in "${Modes[@]}"; do
    if [[ $mod = "$mode" ]];
    then
        match=1
        break
    fi
done

# Check if the user provided all the required arguments and values
if [ "$mode" !=  "" ] && [ $match !=  0 ] && [ "$input" != "" ]
then
    ${mode}
else
    usage
fi
