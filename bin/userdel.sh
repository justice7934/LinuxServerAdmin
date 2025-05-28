#!/bin/bash

cat /root/bin/passwd.txt | while read UNAME UPASS
do
	userdel -r $UNAME
done

