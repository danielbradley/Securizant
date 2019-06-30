#!/system/software/bin/bash
#
#	create_temporary_home.sh
#
#	Copyright (C) 2008 Daniel Robert Bradley
#
#	Creates a tempory home directory on /system/mounts/TEMP

#	Environment variables
HOME="${HOME}"
USER="${USER}"

#	Global constants
DEFAULT_USER_DIR="/system/default/settings/users/skel"
NULL="/system/devices/null"
TEMPDIR="/system/mounts/TEMP"
USERS_DIR_NAME="users"

#	Commands
CHMOD=/system/software/bin/chmod
CP=/system/software/bin/cp
MKDIR=/system/software/bin/mkdir

main()
{
	local Users="${TEMPDIR}/${USERS_DIR_NAME}"
	local NewHome="${Users}/${USER}"

	"${MKDIR}" -p "${Users}"
	"${MKDIR}" "${NewHome}" > "${NULL}" 2>&1
	if [ $? -eq 0 ]
	then
		#
		#	Set permissions on tempory home directory
		#	and copy in default items and any from
		#	the read only directory if it exists.

		"${CHMOD}" 700 "${NewHome}"
		"${CP}" -Rp "${DEFAULT_USER_DIR}"/* "${NewHome}"

		if [ ! "${HOME}" -ef "${NewHome}" -a -f "${HOME}"/* ]
		then
			"${CP}" -Rp "${HOME}"/* "${NewHome}"
		fi
	fi

	echo "${NewHome}"
}

main "$@"
