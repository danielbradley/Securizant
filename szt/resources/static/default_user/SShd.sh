#!/system/software/bin/bash

sshd=`find /system/software/services -name "sshd"`

if [ -x "$sshd" ]
then
	"$sshd"
fi
