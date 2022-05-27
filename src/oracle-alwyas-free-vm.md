# Trying out always free ARM VMs in oracle cloud
<p class="date">May 26, 2022</p>

I was looking for some cheap cloud providers to provision a simple vm
instance. I just wanted to run wireguard and connect my home network to
it so that I can access my homelab clusters and personal PC from public
internet securely. Previously I used digitalocean and hetzner. They both
are cheap, with just 5$ per month for a single core 1GB RAM machine.

Recently I came across oracle cloud. Oracle provides a few always free
resources, which includes 4 ARM cpus with 24GB. Not many people are a
fan of ARM machines, But it was perfect for my use case. Actually it is
more than enough for me, and completely free for life!

You can find more details here:
<https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm>

Although the console is not as user friendly as compared to other cloud
providers, I was able to set it up quickly. One thing which annoyed me
the most is that you are not allowed to create resources in every
region (for free users). You have to choose a home region and then it is
not possible to change it. Then you are stuck with this region forever.
So keep that in mind before creating an account.

Regarding the VM, I have used Ubuntu 20.04 4ARM cpus and 24GB for my
machine. It is also possible to create multiple machines as long as the
total cpu and memory is under the free tier limit. Another thing I've
noticed is that, the network interface in the VM doesn't show the public IP
of the machine. I'm no network expert, but my guess is that there is
some sort of NAT going on to this machine.

Coming to wireguard, the setup was pretty straightforward. I used the
script from <https://github.com/angristan/wireguard-install>  to install
the server and setup the client configurations. I didn't expect it work
in the first try, as I thought the script was meant for intel only. It
worked anyway.
But oracle decided to surprise me again. I was unable to connect to the
wireguard server from my local machine. I tried editing the security
groups, bound a new security group to the instance and still it didn't
work. After a bit of search, I found the answer here: <https://stackoverflow.com/questions/54794217/opening-port-80-on-oracle-cloud-infrastructure-compute-node>.
There were some IPTables rules which blocked the ports to wireguard.
Since I couldn't make sense of the rules, I just dropped the whole set
of rules and it worked..
