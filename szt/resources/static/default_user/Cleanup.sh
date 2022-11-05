#!/system/software/bin/bash

function main()
{
	if [ -d "/sfs" ]
	then
		local script=`find /sfs -noleaf -name "vfs.script"`

		if [ -n "$script" ]
		then
			local szt=`dirname "$script"`

			if [ -d "$szt" ]
			then
				cd /local/bos/checkouts/BOS/bos/bin; ./unmount "$szt"
				cd /local/bos/checkouts/BOS/bos/bin; ./loclean
			fi
		fi
	fi
}

main "$@"

