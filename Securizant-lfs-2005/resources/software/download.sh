#
# download.sh
#
# Downloads software from securizant source server

download()
{
	local Cd=`pwd`
	local Src="$1"	#  eg. "http://www.securizant.org/source"
	local Dir="$2"	#  eg. "core/libraries"
	local Pkg="$3"	#  eg. "gettext-0.14.3.tar.bz2" 

	if [ -z "${Src}" -o -z "${Dir}" -o -z "${Pkg}" ]
	then
		echo "Download: incorrect parameters: \"${Src}\" \"${Dir}\" \"${Pkg}\""
		return -1
	fi
	
	echo "Download: \"${Src}\" \"${Dir}\" \"${Pkg}\"" &&

	if [ ! -f "/mnt/source/${Dir}/${Pkg}" ]
	then
		if [ ! -d "/mnt/source/${Dir}" ]
		then
			mkdir -p "/mnt/source/${Dir}" &&
			mkdir -p "/system/features/source/${Dir}"
		fi
	
		cd "/mnt/source/${Dir}" &&
		wget "${Src}/${Dir}/${Pkg}" &&
		cp "${Pkg}" "/system/features/source/${Dir}" &&
		cd ${Cd}
	fi
}
