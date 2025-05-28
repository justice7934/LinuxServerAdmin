#!/bin/bash

> /root/bin/passwd.txt

for i in {50..80}
do
	echo "user$i  user$i" >> /root/bin/passwd.txt
done

