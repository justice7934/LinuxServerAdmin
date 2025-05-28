#!/bin/bash

cat /root/bin/passwd.txt | while read USER_NAME PASSWD
do
       useradd $USER_NAME
       echo $PASSWD | /usr/bin/passwd --stdin $USER_NAME
done

