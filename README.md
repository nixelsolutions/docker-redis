# docker-redis
## Prerequisites:

* You need three nodes for deploying this redis cluster
* Every node should reach other nodes on 6379/tcp and 26379/tcp ports
* You need to install docker-compose +1.5 on three nodes:

```
curl -L https://github.com/docker/compose/releases/download/1.6.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

## How to start the redis cluster

### On server1

* Copy docker-compose-redis1.yml file
* Make sure to export these environment variables:

```
NODE1_IP
```

Where:
- *NODE1_IP* is the IP address of the binding interface on server1.

For example:

```
export NODE1_IP=10.0.1.1
```

* Now execute docker-compose to create the container:

```
docker-compose -f docker-compose-redis1.yml up -d
```

### On server2

* Copy docker-compose-redis2.yml file
* Make sure to export these environment variables:

```
NODE1_IP
NODE2_IP
```

Where:
- *NODE1_IP* is the IP address of the binding interface on server1.
- *NODE2_IP* is the IP address of the binding interface on server2.

For example:

```
export NODE1_IP=10.0.1.1
export NODE2_IP=10.0.1.2
```

* Now execute docker-compose to create the container:

```
docker-compose -f docker-compose-redis2.yml up -d
```

### On server3

* Copy docker-compose-redis3.yml file
* Make sure to export these environment variables:

```
NODE1_IP
NODE3_IP
```

Where:
- *NODE1_IP* is the IP address of the binding interface on server1.
- *NODE3_IP* is the IP address of the binding interface on server3.

For example:

```
export NODE1_IP=10.0.1.1
export NODE3_IP=10.0.1.3
```

* Now execute docker-compose to create the container:

```
docker-compose -f docker-compose-redis3.yml up -d
```


## Testing the cluster

This command:

```
redis-cli -h ${NODE1_IP} info
```

Should print something similar to this:

```
# Replication
role:master
connected_slaves:2
slave0:ip=10.0.1.2,port=6379,state=online,offset=12567320,lag=0
slave1:ip=10.0.1.3,port=6379,state=online,offset=12567175,lag=0
```

These commands:

```
redis-cli -h ${NODE2_IP} info
redis-cli -h ${NODE3_IP} info
```

Should print something similar to this:

```
# Replication
role:slave
master_host:10.0.1.1
master_port:6379
master_link_status:up
master_last_io_seconds_ago:0
master_sync_in_progress:0
```
