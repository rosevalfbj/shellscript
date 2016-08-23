#!/bin/bash

while [ $# -gt 0 ]; do
        case $1 in
                "-p")
                        shift
                        APPLICATION=$1
                ;;
                "-w")
                        shift
                        WARN=$1
                ;;
                "-c")
                        shift
                        CRIT=$1
                ;;
                *)
                        echo "Use $0 -p [Application] -w [Warning] -c [Critical]"
                        exit 3
                ;;
        esac
        shift
done

if [ -z "${APPLICATION}" ] || [ -z "${WARN}" ] || [ -z "${CRIT}" ] ; then
        echo "Use $0 -p [Application] -w [Warning] -c [Critical]"
        exit 3
fi

CONTEXT_APP="/${APPLICATION}/"
PATH_LOG="/jboss/jboss-4.2.3.GA/server/default/log"
FILE_LOG="localhost_access_log."
PATH_LASTLINE_LOG="/usr/local/nagios/libexec"
FILE_CTRL_LOG="${APPLICATION}_ctrl"
FILE_AVG_LOG="${APPLICATION}_avg"
CALC_AVG_LOG="${APPLICATION}_calc"
DATE=`date +%Y-%m-%d`
TIMESTAMP=`date +%Y-%m-%d_%H:%M:%S`

if [ `tail -n 1 ${PATH_LASTLINE_LOG}/${FILE_CTRL_LOG}| wc -l` == '0' ]; then
	TOTAL_LINE=0
else TOTAL_LINE=`tail -n 1 ${PATH_LASTLINE_LOG}/${FILE_CTRL_LOG} | awk -F ";" '{print $4}'| awk -F ":" '{print $2}'`
fi
tail -n +${TOTAL_LINE} ${PATH_LOG}/${FILE_LOG}${DATE}.log >> ${PATH_LASTLINE_LOG}/${FILE_AVG_LOG}
cat ${PATH_LASTLINE_LOG}/${FILE_AVG_LOG} | grep -i "${CONTEXT_APP}" | awk -F " " '{NF = NF - 1} {print $NF}' >>  ${PATH_LASTLINE_LOG}/${CALC_AVG_LOG}
## SUM values of file
for line in `cat ${PATH_LASTLINE_LOG}/${CALC_AVG_LOG}`; do
	SUM_APP=$[${SUM_APP} + ${line}]
done

#### Prepare control file #####
AMOUNT_LINE_APP=`cat ${PATH_LASTLINE_LOG}/${FILE_AVG_LOG} | grep -i "${CONTEXT_APP}" | wc -l`
AMOUNT_LINE_OTHER=`cat ${PATH_LASTLINE_LOG}/${FILE_AVG_LOG} | grep -v "${CONTEXT_APP}" | wc -l`
TOTAL_LINE_AFTER=`cat ${PATH_LOG}/${FILE_LOG}${DATE}.log | wc -l`

if [ ${AMOUNT_LINE_APP} -eq 0 ]; then
        echo "JMX OK: ${APPLICATION} AVG_RespTime=${AMOUNT_LINE_APP}ms | AVG_RespTime=${AMOUNT_LINE_APP};Warn=${WARN};Critical=${CRIT}"
        exit 0;
fi

#### Reset Values
> ${PATH_LASTLINE_LOG}/${FILE_AVG_LOG}
> ${PATH_LASTLINE_LOG}/${CALC_AVG_LOG}

#### Show values
AVG_APP=$[ ${SUM_APP} / ${AMOUNT_LINE_APP} ]
#echo "AvgRespTime:${AVG_APP}ms/req-SumRespTime:${SUM_APP}ms-AmountTotalReq:${AMOUNT_LINE_APP}|ResponseTimeAVG=${AVG_APP}"
echo "Date:${TIMESTAMP};Sum Response Time: ${SUM_APP};Total line Before:${TOTAL_LINE};Total line after:${TOTAL_LINE_AFTER};Lines App:${AMOUNT_LINE_APP};Lines Other:${AMOUNT_LINE_OTHER};Average Response Time: ${AVG_APP}" >> ${PATH_LASTLINE_LOG}/${FILE_CTRL_LOG}

if [ "${AVG_APP}" -lt "${WARN}" ] ; then
        echo "JMX OK: ${APPLICATION} AVG_RespTime=${AVG_APP}ms | AVG_RespTime=${AVG_APP};Warn=${WARN};Critical=${CRIT}"
        exit 0
elif [ "${AVG_APP}" -ge "${WARN}" ] && [ "${AVG_APP}" -lt "${CRIT}" ] ; then
        echo "JMX WARNING: ${APPLICATION} AVG_RespTime=${AVG_APP}ms | AVG_RespTime=${AVG_APP};Warn=${WARN};Critical=${CRIT}"
        exit 1
else
        echo "JMX CRITICAL: ${APPLICATION} AVG_RespTime=${AVG_APP}ms | AVG_RespTime=${AVG_APP};Warn=${WARN};Critical=${CRIT}"
        exit 2
fi
