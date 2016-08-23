#/bin/bash
while [ $# -gt 0 ]; do
        case $1 in
		"-d")
                        shift
                        DATASOURCE=${1}
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
                        echo "Use $0 -d [Datasource] -h [Host] -p [Port]"
                        exit 3
                ;;
        esac
        shift
done

COMMAND_CLI="/subsystem=datasources/data-source=${DATASOURCE}:test-connection-in-pool"
COMMAND_JBOSS="/jboss/jboss-as-7.1.1/bin/jboss-cli.sh --connect controller=${SERVER}:${SERVER_PORT} --command=\"${COMMAND_CLI}\" "


COMMAND=`sudo su - jboss -c "${COMMAND_JBOSS}"| awk '$1=="\"outcome\"" {print $3}'|awk -F "," '{print $1}'| sed 's/\"//g'`
RESULT=${COMMAND}

#echo "RESULT: " ${RESULT}

if [ "${RESULT}" = "" ]; then
    exit 2;
else if [ ${RESULT} = "success" ]; then
        echo "OK: Datasource ${DATASOURCE} com sucesso | status=0"
        exit 0;
     else echo "Critical: Datasource ${DATASOURCE} com erro | status=2"
            exit 2;
     fi
fi
