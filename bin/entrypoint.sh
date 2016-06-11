#!/bin/bash

set -e

if [ -z "${MY_IP}" -o "${MY_IP}" == "**ChangeMe**" ]; then
  echo "ERROR MY_IP variable is not defined - Exiting..."
  exit 1
fi

#sleep 5
#RANCHER_NODES=`dig +short ${RANCHER_SERVICE_NAME} | sort`
#if [ ! -z "${RANCHER_NODES}" ]; then
#  export MASTER_IP=`echo "${RANCHER_NODES}" | head -1`
#  export MY_IP=`ip addr | grep inet | grep 10.42 | tail -1 | awk '{print $2}' | awk -F\/ '{print $1}'`
#fi

if [ -z "${MASTER_IP}" -o "${MASTER_IP}" == "**ChangeMe**" ]; then
  echo "ERROR MASTER_IP variable is not defined - Exiting..."
  exit 1
fi

if [ -z "${MY_IP}" -o "${MY_IP}" == "**ChangeMe**" ]; then
  echo "ERROR MY_IP variable is not defined - Exiting..."
  exit 1
fi

# Configuration
perl -p -i -e "s/^port .*/port ${REDIS_PORT}/g" /etc/redis.conf
perl -p -i -e "s/^daemonize .*/daemonize no/g" /etc/redis.conf
perl -p -i -e "s/^appendonly .*/appendonly yes/g" /etc/redis.conf
if [ "${MY_IP}" != "${MASTER_IP}" ]; then
  perl -p -i -e "s/^#? ?slaveof .*/slaveof ${MASTER_IP} ${MASTER_PORT}/g" /etc/redis.conf
fi

perl -p -i -e "s/^port .*/port ${SENTINEL_PORT}/g" /etc/sentinel.conf
perl -p -i -e "s/^#? ?sentinel announce-ip .*/sentinel announce-ip ${MY_IP}/g" /etc/sentinel.conf
perl -p -i -e "s/^#? ?sentinel announce-port .*/sentinel announce-port ${SENTINEL_EXPOSED_PORT}/g" /etc/sentinel.conf
perl -p -i -e "s/^sentinel monitor .*/sentinel monitor  mymaster ${MASTER_IP} ${MASTER_PORT} ${REDIS_QUORUM}/g" /etc/sentinel.conf
perl -p -i -e "s/^sentinel down-after-milliseconds .*/sentinel down-after-milliseconds mymaster ${REDIS_MASTER_TIMEOUT}/g" /etc/sentinel.conf
perl -p -i -e "s/^sentinel failover-timeout .*/sentinel failover-timeout mymaster ${REDIS_FAILOVER_TIMEOUT}/g" /etc/sentinel.conf

if [ -z "$1" -o "$1" == "" ]; then
  chown -R ${USER} .
  exec /usr/bin/supervisord
fi

exec "$@"
