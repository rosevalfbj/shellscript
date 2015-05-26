#!/bin/bash

while [ $# -gt 0 ]; do
        case $1 in
                "-p")
                        shift
                        PROCESS=$1
                ;;
                "-v")
                        shift
                        VLE=$1
                ;;
                "-w")
                        shift
                        WARN=$1
                ;;
                 "-c")
                        shift
                        CRITICAL=$1
                ;;
                *)
                       echo "Use $0 -p [Process name java] -v [Value mega bytes monitory java] -w [Warn at %]  -c [Critical at %]"
                       exit 3
                ;;
        esac
        shift
done

if [ -z "${PROCESS}" ] || [ -z ${VLE} ] || [ -z ${WARN} ] || [ -z ${CRITICAL} ];then
    echo "Use $0 -p [Process name java] -v [Value mega bytes monitory java] -w [Warn at %]  -c [Critical at %]"
        exit 3
fi

#Capture the values
MEM_RSS=`ps -eo rss,command | grep java | grep -w ${PROCESS}| grep -v grep |awk -F " " '{ print $1 }'`
MEM_VRT=`ps -eo size,command | grep java | grep -w ${PROCESS}| grep -v grep |awk -F " " '{ print $1 }'`

#Convert in percentage
VLE=`expr ${VLE} \* 1000`
MEM_RSS_PER=`expr ${MEM_RSS} \* 100`
MEM_RSS_PER=`expr ${MEM_RSS_PER} / ${VLE}`
MEM_VRT_PER=`expr ${MEM_VRT} \* 100`
MEM_VRT_PER=`expr ${MEM_VRT_PER} / ${VLE}`

#Convert the consumption in MegaBytes
MEM_RSS_MB=`expr ${MEM_RSS} / 1024`
MEM_VRT_MB=`expr ${MEM_VRT} / 1024`

if [ ${MEM_VRT_PER} -ge ${WARN} ] && [ ${MEM_VRT_PER} -le ${CRITICAL} ];then
    echo "WARN - ${PROCESS} - RSS=${MEM_RSS_PER}% - VRT=${MEM_VRT_PER}% | USAGE_RSS="${MEM_RSS_MB}"MB | USAGE_VRT="${MEM_VRT_MB}"MB"
    exit 1
elif [ ${MEM_VRT_PER} -ge ${CRITICAL} ];then
    echo "CRITICAL - ${PROCESS} - RSS=${MEM_RSS_PER}% - VRT=${MEM_VRT_PER}% | USAGE_RSS="${MEM_RSS_MB}"MB | USAGE_VRT="${MEM_VRT_MB}"MB"
    exit 2
else
    echo "OK - ${PROCESS} - RSS=${MEM_RSS_PER}% - VRT=${MEM_VRT_PER}% | USAGE_RSS="${MEM_RSS_MB}"MB | USAGE_VRT="${MEM_VRT_MB}"MB"
    exit 0
fi

######################################### FIM #################################################################################
#How to execute:

#./check_processMemJar.sh -p java -v 2000 -w 80 -c 90
#-p = process
#-v = virtual memory that the process can achieve
#-w = percentage value for warning
#-c = percentage value for critical
#The comparison of the JAR process consumption will be via parameter -v, for example 2000, equals 2 GB.
