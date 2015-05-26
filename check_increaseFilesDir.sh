#!/bin/bash

PATH_ATTACH="/opt/attach"

while [ $# -gt 0 ]; do
        case $1 in
                "-v")
                        shift
                        VALUE=$1
                ;;
        "-p")
                        shift
                        PARAMETER=$1
                ;;
                *)
                        echo "Use $0 -v [disk/files] -p [days]; example: ./check_increaseFilesDir.sh -v disk -p 30"
                        exit 3
                ;;
        esac
        shift
done

if [ -z "${PARAMETER}" ]  || [ -z "${VALUE}" ] ; then
        echo "Use $0 -v [disk/files] -p [days]; example: ./check_increaseFilesDir.sh -v disk -p 30"
        exit 3
fi

if [ ${VALUE} == "disk" ];then
    PARAM="\$1"
    RETURN=`find ${PATH_ATTACH} -type f  -mtime -${PARAMETER} -print0 | xargs -0 du -b | awk '{print $1}' | awk ' { sum += '${PARAM}'; } END { print "Total Usage Disk Attachments: "sum/1024/1024 "MB | usage=" sum/1024/1024"MB" }'`

elif [ ${VALUE} == "files" ];then
    PARAM="1"
    RETURN=`find ${PATH_ATTACH} -type f  -mtime -${PARAMETER} -print0 | xargs -0 du -b | awk '{print $1}' | awk ' { sum += '${PARAM}'; } END { print "Total Usage Files Attachments: " sum " | usage=" sum }'`

else echo "Parameter not found !!"
     exit 3;

fi

echo ${RETURN}
exit 0

############################################################ FIM ################################################################
