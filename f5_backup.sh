#!/bin/bash
#Set the date variable for the UCS filename
today=$(date +'%Y%m%d')
#Set the device name for the UCS filename
host=HOSTNAME_FOR_UCS
#Set the IP or FQDN, save path, Username and Password for the FTP Server
ftploc="File location to save on ftp i.e. /f5/uploads"
ftphost="FTP_ADDRESS"
user="FTP_USER"
password="FTP_PASSWORD"
#Set the temp location to save the UCS for creation, rename, and upload"
loc="File location to save on ftp i.e. /var/tmp"
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
cd $ftploc
put $config-$host-$today.ucs
close
bye
EOF
# Delete the backed up config file.
rm -rf $loc/config-$host-$today.ucs
