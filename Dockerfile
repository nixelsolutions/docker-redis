FROM ubuntu:14.04

ENV USER redis

RUN groupadd -r ${USER} && useradd -r -g ${USER} ${USER}

RUN apt-get update && apt-get install -y ca-certificates curl supervisor dnsutils

ENV REDIS_VERSION 3.0.4
ENV REDIS_DOWNLOAD_URL http://download.redis.io/releases/redis-3.0.4.tar.gz
ENV REDIS_DOWNLOAD_SHA1 cccc58b2b8643930840870f17280fcae57ed7675

RUN buildDeps='gcc libc6-dev make' \
	&& set -x \
	&& apt-get update && apt-get install -y $buildDeps --no-install-recommends \
	&& rm -rf /var/lib/apt/lists/* \
	&& mkdir -p /usr/src/redis \
	&& curl -sSL "$REDIS_DOWNLOAD_URL" -o redis.tar.gz \
	&& echo "$REDIS_DOWNLOAD_SHA1 *redis.tar.gz" | sha1sum -c - \
	&& tar -xzf redis.tar.gz -C /usr/src/redis --strip-components=1 \
	&& rm redis.tar.gz \
	&& make -C /usr/src/redis \
	&& make -C /usr/src/redis install \
        && cp /usr/src/redis/redis.conf /etc/ \
        && cp /usr/src/redis/sentinel.conf /etc/ \
	&& rm -r /usr/src/redis \
	&& apt-get purge -y --auto-remove $buildDeps

ENV REDIS_PORT 6379
ENV SENTINEL_PORT 26379
ENV SENTINEL_EXPOSED_PORT ${SENTINEL_PORT}
ENV REDIS_QUORUM 2
ENV REDIS_MASTER_TIMEOUT 10000
ENV REDIS_FAILOVER_TIMEOUT 60000

ENV RANCHER_SERVICE_NAME redis
ENV MASTER_IP **ChangeMe**
ENV MASTER_PORT ${REDIS_PORT}
ENV SLAVE_IP **ChangeMe**
ENV MY_IP **ChangeMe**

RUN mkdir /data && chown -R ${USER}:${USER} /data
VOLUME /data
WORKDIR /data

EXPOSE ${REDIS_PORT}
EXPOSE ${SENTINEL_PORT}

RUN mkdir -p /usr/local/bin
ADD ./bin /usr/local/bin
RUN chmod +x /usr/local/bin/*.sh
ADD ./etc /etc

ENTRYPOINT ["entrypoint.sh"]
