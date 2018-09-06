#!/bin/bash
echo "Drcom CAUC Login Client, developed by XiaoLu."
echo
if [ $# -eq 2 ]
then
    echo "Your Username: $1"
    echo "Your Password: $2"
    wget
    if [ $? -eq 127 ]
    then
        echo "[*] wget: command not found, try to use curl instead."
        curl
        if [ $? -eq 127 ]
        then
            echo "[-] curl: command not found"
            echo
            echo "You must install wget or curl package to run this script."
            echo "Try to use yum or apt-get to install them."
        else
            echo "[*] Warning: Your password will be sent to the server without encrypt for the weak authorization method of our school network."
            curl --data-urlencode "R1=0&R3=0&R6=0&para=00&MKKey=123456" --data-urlencode "DDDDD=$1" --data-urlencode "upass=$2" --data-urlencode "C1=on" "http://192.168.100.200/a70.htm" | grep errorMsg
            curl http://ip.chinaz.com/getip.aspx
            echo
        fi
    else
        echo "[*] Warning: Your password will be sent to the server without encrypt for the weak authorization method of our school network."
        wget --post-data "DDDDD=$1&upass=$2&R1=0&R3=0&R6=0&para=00&MKKey=123456" http://192.168.100.200/a70.htm
        cat a70.htm | grep errorMsg
        rm a70.htm
    fi
elif [ $# -eq 1 ]
then
    if [ $1 = "-h" -o $1 = "--help"]
    then
        echo "Usage: cauclogin.sh [Username] [Password]"
    else 
        echo "[-] cauclogin.sh: require 2 parameters, but $# parameter(s) are given."
    fi
elif [ $# -eq 0 ]
then
    echo "[-] cauclogin.sh: missing username and password"
    echo "Usage: cauclogin.sh [Username] [Password]"
    echo
    echo "Try cauclogin.sh -h or cauclogin.sh --help for more options."
else 
    echo "[-] cauclogin.sh: require 2 parameters, but $# parameter(s) are given."
fi