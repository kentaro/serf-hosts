# Automatic `/etchosts` management with Serf

## Usage

### First Node

Launch a serf agent named `node1`:

```
$ serf agent -node=node1 -bind=127.0.0.10 -rpc-addr=127.0.0.1:7374 -event-handler=event_handler.pl
```

Then you'll see `etc/hosts` to be like below:

```
$ cat etc/hosts
127.0.0.10      node1
```

### Second Node

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
  2. `member-join` event is occurred
  3. `node2` is added into `etc/hosts`

```
$ cat etc/hosts
127.0.0.10      node1
127.0.0.11      node2
```

### Second Node Leaves

Push `Ctrl-C` to stop `node2`. Then `member-leave` event is propagated to `node1` and the handler script is fired.

As a result,

  1. `node2` is now not a member of the cluster
  2. `member-leave` event is occurred
  3. `node2` is removed from `etc/hosts`

```
$ cat etc/hosts
127.0.0.10      node1
```

