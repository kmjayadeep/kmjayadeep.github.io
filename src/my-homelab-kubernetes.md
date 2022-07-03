# My experiments with Homelab Kubernetes cluster
<p class="date">July 03, 2022</p>

Here I would like to share my experience building a simple homelab
Kubernetes cluster on a cheap mini PC. I have learned a lot of things
about networking, disaster recovery etc. Hopefully this will be useful
for someone else with similar interests.

My machine is an old Fujitzu 920, with i5 processor, 16gigs of ram and
256GB SSD storage. Since I don't have any actual workloads to run, this
is more than enough for me. My aim is to learn some networking stuff
and get more hands on experience with Kubernetes on-prem setup.

## Setting up the OS and Networking

I chose `Ubuntu Server 22.04` as the base OS. This was a no brainer. Ubuntu server is stable, has good community support and is
designed to be ran as a server OS. I thought of installing an Arch based
distro like Manjaro since I'm a huge fan of Arch Linux. But I got lazy
and went ahead with ubuntu anyway.

Installation was easy. Just flash the iso to a USB drive, boot into it
and use the installtion wizard. The setup wizard was intuitive to use. I
had an ethernet adapter to connect to internet. I preferred ethernet
cable rather than wifi, as it is much faster. But I couldn't connect to
ethernet during the setup. I needed a monitor to do the OS setup, but
the router was far away from where the ethernet cable can reach. So, I
had to use a wifi dongle during the installation. I have assigned a
static IP from router to the wifi mac address and tested ssh conection
from my main PC. Then I kept the wifi dongle plugged in, moved the server pc to near the router, plugged in ethernet cable and
booted up. All good. I can ssh into the server.

Next, I wanted to remove the wifi dongle and make sure it will connect
to ethernet and always have the same IP on reboot. For this, I have used
`netplan` <https://netplan.io/>. The is how my netplan config looks
like (I will talk about the ipv6 stuff later)



/etc/netplan/00-installer-config.yaml
```
network:
    version: 2
    ethernets:
        enp0s25:
            dhcp4: no
            match:
                macaddress: XX:XX:XX:XX:XX
            mtu: 1500
            set-name: enp0s25
            dhcp6: no
            addresses:
                - XXXXXXX/64
                - XXXXX/24
            routes:
                - to: XXXX::1
                  scope: link
                - to: default
                  via: XXX::1
                  on-link: true
                - to: default
                  via: XX
            nameservers:
                addresses:
                    - 1.1.1.1
                    - 8.8.8.8
```

As you can see it disables `dhcp` and assigns static IPv4 and IPv4
address to the ethernet interface. I did a quick test by rebooting the
server and it looked good. Time to remove the dongle!


## K3s - Lightweight Kubernetes

I didn't even have to think about this. I have used k3s before. It is
lightweight Kubernetes distribution, which is very easy to setup and
maintain. It just has a single binary and no dependencies. <https://k3s.io/>

But there were a few configurations I needed to tweak in order to get it to
work the way i wanted. Here is the command I used to set it up.


```
export INSTALL_K3S_VERSION=v1.23.5+k3s1
export INSTALL_K3S_EXEC="server --disable traefik --disable servicelb --disable metrics-server --disable-cloud-controller \
       --kube-proxy-arg proxy-mode=ipvs --cluster-cidr=10.63.0.0/16,fd63::/48 --service-cidr=10.90.0.0/16,fd90::/112 \
       --disable-network-policy --flannel-backend=none --node-ip=XXXXX,XXXXXXXXXX --disable local-storage"
wget https://get.k3s.io -O k3s.sh
less k3s.sh
bash k3s.sh
```

Here are the changes I did compared to default options. I will explain
the reasoning behind them later. I didn't come up with this
configuration in the first try. I had to reinstall many many times to
get it the right way. I have learned during a later stage that I needed
ipv6 support in order to get public traffic. It forced me to re
configure the network stack (hence the ipv6 config in netplan) and k3s
config later. It is why I had to provide node-ip in ipv4 and ipv6 in the
above config.

Changes:

* Disabled traefik controller - I wanted to use nginx for this
* Disable metrics-server - I have installed and managed them through gitops later
* Disable servicelb - I prefer metallb as a loadbalancer
* Disable cloud-controller - Didn't need it
* Set cluster and service cidr - This was needed for calico
* Disable network policy - I wasn't planning to use it
* Disable local-storage - I had to use a customized version of this due
  to a bug. More info later
* Disable flannel - I had to use calico as flannel wasn't supporting
  ipv6 (as far as I know)

Once the above command is ran, cluster was ready in a few seconds. Then
it is just a matter of copying kubeconfig to my personal machine, so
that I can continue using `kubectl` commands from there instead of
sshing into the machine every time.


in server
```
sudo cp /etc/rancher/k3s/k3s.yaml .
sudo chown pluto:pluto k3s.yaml 
```
in local

```
scp pluto:/home/pluto/k3s.yaml .
```

After copying the yaml file, I had to edit and adjust the server IP
address. By default, it will be configured as `127.0.0.1`. I just
replaced it with the server lan IP.
