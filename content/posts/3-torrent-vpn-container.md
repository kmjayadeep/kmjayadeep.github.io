+++
title = "Running Torrrent with VPN in a container"
description = "Setup Deluge torrent client with VPN and a fail-safe kill-switch"
date = "2022-05-30"
tags = ["vpn", "homelab", "articles"]
author = "Jayadeep KM"
toc = false
+++

Torrent is one of the fastest ways to share files across internet
without having a central distribution point. But the major disadvantage
of torrent is that it exposes the public IP of the users to everyone who
has access to that torrent file. This is dangerous for a number of
reasons. My concern is not about hackers or anything like that. I live
in a country where torrent is "considered" to be illegal. It is not
illegal as per law, but we can expect some letters from the ISP if we
download any copyrighted stuff from torrent. That is not a big deal for
me, as I don't download any pirated movies or anything from torrent. But
I still hate the fact that people can easily identify me using public IP
when using torrent.

I could purchase a seedbox and use it to download torrents. But I wanted
to try to setup a torrent client through VPN. That's when I came across
this: <https://github.com/binhex/arch-delugevpn>. It is a docker
container which has a deluge torrent client (web based) and vpn running
alongside it. It also has a kill switch which will stop the torrent when
vpn is disconnected. In a previous post [Trying out always free ARM VMs in oracle cloud ](/posts/oracle-alwyas-free-vm.html)
I have explained how I have setup wireguard vpn in oracle ARM VMs using
[wireguard install](https://github.com/angristan/wireguard-install)
script. I'm going to use that to setup arch-delugevpn with wireguard in
my machine.

I wrote a docker-compose file from the docker run commands mentioned in
the github readme, taking inspiration from this [youtube video](https://www.youtube.com/watch?v=5Tls2LRKh-c).

```yaml
version: '3'
services:
  delugevpn:
    container_name: delugevpn
    image: binhex/arch-delugevpn:latest
    restart: unless-stopped
    sysctls:
    - net.ipv4.conf.all.src_valid_mark=1
    privileged: true
    ports:
      - 0.0.0.0:8112:8112
      - 58846:58846
      - 58946:58946
      - 0.0.0.0:8118:8118
    environment:
      - VPN_ENABLED=yes
      - VPN_PROV=custom
      - VPN_CLIENT=wireguard
      - ENABLE_PRIVOXY=yes
      - LAN_NETWORK=192.168.1.0/24 # Replace with your network's IP
      - NAME_SERVERS=1.1.1.1,1.0.0.1
      - DELUGE_DAEMON_LOG_LEVEL=info
      - DELUGE_WEB_LOG_LEVEL=info
      - DEBUG=false
      - UMASK=000
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Berlin # Replace with your timezone – check https://en.wikipedia.org/wiki/List_of_tz_database_time_zones for reference
    volumes:
      - /home/jayadeep/docker-volumes/deluge-data:/data
      - ./config:/config
      - /etc/localtime:/etc/localtime:ro
```

In the volumes section, you can notice that there is a `config` folder
and a `data` folder. I kept the config folder along with the
docker-compose file and data in a separate location. Now all you have to
do is copy the wireguard config to the `config/wireguard` folder and
start the container.

```
docker-compose up
```

It will connect the vpn, start deluge client and also expose a proxy on
port 8112. You can configure this proxy (localhost:8112) in your
applications or browser to route the traffic from specific apps through
VPN, while keeping the rest of the apps in the public network.

Make sure to check for IP leaks before downloading anything from
torrent. I used this website <https://www.top10vpn.com/tools/do-i-leak/>
and <https://torguard.net/checkmytorrentipaddress.php> to ensure that my
public IP is not exposed.

**Another word of caution:** If you are hosting your own vpn, the IP
address can be still traced back to you. Copyright owners of pirated
content can contact the ISP of the cloud provider and they can terminate
your account or take legal actions.
