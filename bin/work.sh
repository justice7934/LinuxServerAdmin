#!/bin/bash

echo "System test service" | logger -t Testsystemd
while true
do
	echo "Running systemd"
	sleep 30
done
