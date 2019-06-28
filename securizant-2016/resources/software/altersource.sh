#
#  altersource.sh
#
#  altersource <top directory> <string 1> <string 2> [file suffix]
#
#  Substitutes <string 1> for <string 2> in all files ending 
#  in <suffix> underneath the <top directory> specified. 
#

function altersource()
{
	local Dir=$1
	local Old=$2
	local New=$3
	local Suffix=$4

	local Files=`grep -lr "${Old}" ${Dir}`

	for File in ${Files}
	do
		local FileBase1=`basename ${File}`
		local FileBase2=`basename ${File} ${Suffix}`
		if [ -z "${Suffix}" ]
		then
			echo "Altering source: ${File}"
			sed -i "s@${Old}@${New}@g" "${File}"
		elif [ "${FileBase1}" == "${FileBase2}${Suffix}" ]
		then
			echo "Altering source: ${File}"
			sed -i "s@${Old}@${New}@g" "${File}"
		elif [ "${FileBase1}" == "${Suffix}" ]
		then
			echo "Altering source: ${File}"
			sed -i "s@${Old}@${New}@g" "${File}"
		fi
		done
}
