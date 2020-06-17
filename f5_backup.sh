#!/bin/bash
# set the date variable
today=$(date +'%Y%m%d')
host=HOSTNAME_FOR_UCS
ftphost="FTP_ADDRESS"
user="FTP_USER"
password="FTP_PASSWORD"
loc=/var/tmp
#run the F5 bigpipe config builder
cd $loc
tmsh save /sys ucs $loc/config.ucs
#Rename the config.ucs and append the date to the end
NUM=0
until [ "$NUM" -eq 5 ]
do
if [ -f $loc/config.ucs ]
then mv $loc/config.ucs $loc/config-$host-$today.ucs ; break
else sleep 5
fi
NUM=`expr "$NUM" + 1`
done
[[ ! -f/$loc/config-$host-$today.ucs ]] && exit 1
#Open the FTP connection and move the file
ftp -in <<EOF
open $ftphost
user $user $password
bin
put config-$host-$today.ucs
close
bye
EOF
# Delete the backedup config file.
rm -rf $loc/config-$host-$today.ucs
