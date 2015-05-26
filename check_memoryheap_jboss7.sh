#/bin/bash
while [ $# -gt 0 ]; do
        case $1 in
		"-h")
			shift
			SERVER=${1}
		;;
		"-p")
			shift
			SERVER_PORT=${1}
		;;
		"-c")
                        shift
                        CRT=${1}
                ;;
                *)
                        echo "Use $0 -h [Host] -p [Port] -c [CRITICAL %]; example: ./check_memoryheap_jboss7.sh -h localhost -p 9999 -c 80"
                        exit 3
                ;;
        esac
        shift
done

if [ -z "${SERVER}" ] || [ -z "${SERVER_PORT}" ] || [ -z "${CRT}" ]; then
        echo "Use $0 -h [Host] -p [Port] -c [CRITICAL %]; example: ./check_memoryheap_jboss7.sh -h localhost -p 9999 -c 80"
        exit 3
fi

USER="jboss"
COMMAND_CLI="/core-service=platform-mbean/type=memory :read-attribute(name=heap-memory-usage)"
COMMAND_JBOSS="/jboss/jboss-as-7.1.1/bin/jboss-cli.sh --connect controller=${SERVER}:${SERVER_PORT} --command=\"${COMMAND_CLI}\" "

COMMAND=`sudo su - ${USER} -c "${COMMAND_JBOSS}" | awk '/init/{gsub("\"","",$1);print $1"="$3} /used/{gsub("\"","",$1);print $1"="$3} /committed/{gsub("\"","",$1);print $1"="$3} /max/{gsub("\"","",$1);print $1"="$3}'|sed 's/L//g'|sed 's/,/;/g'`
RESULT=${COMMAND}
USED=`echo ${RESULT} | awk -F " " '{print $2}'|sed 's/;//g'|awk -F "=" '{print $2}'`
MAX=`echo ${RESULT} | awk -F " " '{print $4}'|sed 's/;//g'|awk -F "=" '{print $2}'`

PERC=`expr ${MAX} / 100`
PERC_MAX=`expr ${PERC} \* ${CRT}`

if [ ${USED} -ge ${PERC_MAX} ];then
	echo "CRITICAL - "${RESULT}" | "${RESULT}
	exit 2
else echo "OK - "${RESULT}" | "${RESULT}
     exit 0
fi
