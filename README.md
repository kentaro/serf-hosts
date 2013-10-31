# Automatic `/etc/hosts` management with Serf

## Problem

In the cloud world, many hosts appear and vanish. Since we don't want to bother to manage some internal DNS service while keeping its availability, we have been updating `/etc/hosts` file periodically with cron and AWS API.

There are, however, several problems in that way of updating `/etc/hosts`:

  1. It's far from real time
  2. There are many other components that need to be updated in a likely way; for example, nagios, munin, etc.

It's laborious that we have to write scripts for each purposes and edit crontab.

## Solution

[Serf](http://www.serfdom.io/) can solve the problem. It provides us decentralized hosts discovery solution. Once we launch serf agents in each hosts, the cluster itself works like it is managed completely. In addition, it's almost real time.

## Example

For Mac OS X uses, please check [this document](http://www.serfdom.io/intro/getting-started/join.html) to circumvent a problem in OS X at first.

### Launch the First Node

Launch a serf agent named `node1`:

```
$ serf agent -node=node1 -bind=127.0.0.10 -rpc-addr=127.0.0.1:7374 -event-handler=event_handler.pl
```

Then you'll see `etc/hosts` to be like below:

```
$ cat etc/hosts
127.0.0.10      node1
```

### Launch the Second Node

Launch another node named `node2`:

```
$ serf agent -node=node2 -bind=127.0.0.11 -rpc-addr=127.0.0.1:7375
```

Then add `node2` into the cluster that currently consists of only `node1`:

```
$ serf join -rpc-addr=127.0.0.1:7374 127.1.0.11
```

As a result,

  1. `node2` is now also a member of the cluster
  2. `member-join` event is emitted
  3. `node2` is added into `etc/hosts`

```
$ cat etc/hosts
127.0.0.10      node1
127.0.0.11      node2
```

### Remove the Second Node from the Cluster

Push `Ctrl-C` to stop `node2`. Then `member-leave` event is propagated to `node1` and the handler script is fired.

As a result,

  1. `node2` is now not a member of the cluster
  2. `member-leave` event is emitted
  3. `node2` is removed from `etc/hosts`

```
$ cat etc/hosts
127.0.0.10      node1
```

## See Also

  * [Serf](http://www.serfdom.io/)

## Author

  * [Kentaro Kuribayashi](http://kentarok.org/)

## License

  * MIT http://kentaro.mit-license.org/
