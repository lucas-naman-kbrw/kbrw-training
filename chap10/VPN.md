# VPN

## Step 0: Set up the VPN for KBRW 

To set up the VPN, use the `confvpn.sh` script given. 

`sudo ./confvpn.sh <id> <password>`

Normally, now the VPN is working. And you should be able to connect to [`http://yp01.priv.qa.kbrw.fr/`](http://yp01.priv.qa.kbrw.fr/).

## Step 1: Shutdown the VPN

Yes, ... The goal of this tutorial is not only to launch the script and play on the internal network. 
The objective is to be able to still use internal ressources even if the VPN is down. So let's 
shutdown the VPN. 

```
sudo systemctl stop strongswan
```

Now if you resfresh the page of the QA you shouldn't be able to access it.

## Step 2: Create a ssh tunnel
Let's create a tunnel between the QA ressources and our `localhost`. 
```
ssh access01.cloud.kbrwadventure.com -L 1234:yp01.priv.qa.kbrw.fr:80
```

Let's talk a bit about this command. This command creates a tunnel on `localhost:1234` to 
`yp01.priv.qa.kbrw.fr:80` through the server `access01.cloud.kbrwadventure.com`. 
This means that if we want to access to `yp01.priv.qa.kbrw.fr:80`, you should 
access to `localhost:1234` and the server `access01.cloud.kbrwadventure.com` will perform the 
query and return the result to our binded port. 

Unfortunately this method is limited. Indeed, if you want then to access to the `qa-sa-user.kbrw.fr:8080`, you will need to rebind it.

## Step 3: Create a socket binding

Now we want to avoid to have to rebind on a diffrent port every server. For that, we will bind the 
port `1111` to `socks5h` protocol that will redirect all the connection that comes through this port 
with the `socks5h` protocol to the given adress. In fact it creates a proxy. 

Let's create a local proxy on our own machine on the port `1112`. (This will have no effect else than have an example)
--proxy socks5h://localhost:1112
```
ssh -D 1112 localhost 
```

Now to access to internet through our proxy we can us the `proxy` option of curl.

```
curl --proxy socks5h://localhost:1112 http://127.0.0.1:8098/ping
OK
```

Now let's use it on a real example: 
We want to connect to the server `sa-order.priv.qa.kbrwadventure.com` with 
ssh via the `access01.cloud.kbrwadventure.com` proxy. 

First, let's edit the file `~/.ssh/config`

``` ssh 
Host sa-order.priv.qa.kbrwadventure.com
  ProxyCommand ssh access01.cloud.kbrwadventure.com nc %h %p
```

Now when you will try to ssh on a host in the `Host` list, you will be redirected through the proxy 
contained in the `ProxyCommand`.

``` bash 
ssh sa-order.priv.qa.kbrwadventure.com
```

We can then add some extension to our browser to navigate through this proxy.
Let's start our proxy on the port 1111
``` bash 
ssh -D 1111  access01.cloud.kbrwadventure.com
```

Then if you have chrome you can install [Proxy Switchy-Omega](https://chrome.google.com/webstore/detail/proxy-switchyomega/padekgcemlokbadohgkifijomclgjgif?hl=en) (else install chrome) and configure the
extension as follow:

|Protocol|Server|Port|
|---|---|---|
|SOCKS5|127.0.0.1|1111|


We can also configure git to fetch the repository through this proxy: 
``` sh
#!/bin/sh
PROXY_IP=127.0.0.1
PROXY_PORT=1111

nc -x${PROXY_IP}:${PROXY_PORT} -X5 $*

#exec socat STDIO SOCKS:localhost:$1:$2,socksport=1111%
```
Where `nc` communicate through our proxy.
Now we need to add to our `.gitconfig`:
``` git 
[core]
    gitproxy = <PATH_TO_THE_SCRIPT>/git_proxy.sh
```

[Back to chapter 10](./chap10.html)
