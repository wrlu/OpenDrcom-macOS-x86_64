#!/bin/bash
echo "Drcom CAUC Login Client, developed by XiaoLu."
echo
if [ $# -eq 2 ]
then
    echo "Username: $1"
    echo "Password: $2"
    wget
    if [ $? -eq 127 ]
    then
        echo "wget: command not found, try to use curl instead."
        curl
        if [ $? -eq 127]
        then
            echo "curl: command not found, you must install wget or curl to run this script."
        else
            curl --data-urlencode "DDDDD=$1" --data-urlencode "upass=$2" --data-urlencode "R1=0" --data-urlencode "R3=0" --data-urlencode "R6=0" --data-urlencode "MKKey=123456" "http://192.168.100.200/a70.htm"
        fi
    else
        wget --post-data "DDDDD=$1&upass=$2&R1=0&R3=0&R6=0&MKKey=123456" http://192.168.100.200/a70.htm
        cat a70.htm
        rm a70.htm
    fi
elif [ $# -eq 1 ]
then
    if [ $1 = "-h" -o $1 = "-help"]
    then
        echo "Usage: cauclogin.sh [Username] [Password]"
    else 
        echo "Require 2 parameters, but $# parameter(s) are given."
    fi
elif [ $# -eq 0 ]
then
    echo "cauclogin.sh: missing username and password"
    echo "Usage: cauclogin.sh [Username] [Password]"
    echo
    echo "Try cauclogin.sh -h or cauclogin.sh -help for more options."
else 
    echo "Require 2 parameters, but $# parameter(s) are given."
fi