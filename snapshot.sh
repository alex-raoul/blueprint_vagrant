#!/bin/sh

NAME=$1

blueprint create ${NAME}
mkdir ${NAME}
cd ${NAME}
puppet resource cron > cron
puppet resource group > group
puppet resource host > host
puppet resource package > package
puppet resource user > user	




