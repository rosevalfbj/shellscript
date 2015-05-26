#/bin/bash
while [ $# -gt 0 ]; do
        case $1 in
                "-w")
                        shift
                        WAR=${1}
                ;;
                "-c")
                        shift
                        CRI=${1}
                ;;
                "-q")
                        shift
                        QUEUE=${1}
                ;;
		"-h")
			shift
			SERVER=${1}
		;;
		"-p")
			shift
			SERVER_PORT=${1}
		;;
                *)
                        echo "Use $0 -w [Warning] -c [Critical] -q [Queue] -h [Host] -p [Port]"
                        exit 3
                ;;
        esac
        shift
done

USER="jboss"

COMMAND_CLI="/subsystem=messaging/hornetq-server=default/jms-queue=${QUEUE}/:read-attribute(name=message-count)"
COMMAND_JBOSS="/jboss/jboss-as-7.1.1/bin/jboss-cli.sh --connect controller=${SERVER}:${SERVER_PORT} --command=\"${COMMAND_CLI}\" "


COMMAND=`sudo su - ${USER} -c "${COMMAND_JBOSS}"| awk '$1=="\"result\"" {print $3}'|sed 's/[^0-9]*//g' `
RESULT=($COMMAND)

if [ "${RESULT}" = "" ]; then
    exit 2;
else if [ ${RESULT} -gt ${CRI} ]; then
        echo "Critical: Queue ${QUEUE} amount of message: ${RESULT} | Amount=${RESULT}"
        exit 2;
     else if [ ${RESULT} -gt ${WAR} ]; then
            echo "Warning: Queue ${QUEUE} amount of  message: ${RESULT} | Amount=${RESULT}"
            exit 1;
          else echo "OK: Queue ${QUEUE} amount of message: ${RESULT} | Amount=${RESULT}"
               exit 0;
          fi
     fi
fi
