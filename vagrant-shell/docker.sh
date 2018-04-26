#!/usr/bin/env bash

echo "Entering Docker Provisoning"
date +"%F %T"

sysctl net.ipv4.ip_forward=1
sysctl net.ipv4.conf.all.forwarding=1
sysctl net.ipv6.conf.default.forwarding=1
sysctl net.ipv6.conf.all.forwarding=1
sysctl net.ipv6.conf.all.accept_ra=2

sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv4.conf.all.forwarding=1
sysctl -w net.ipv6.conf.default.forwarding=1
sysctl -w net.ipv6.conf.all.forwarding=1
sysctl -w net.ipv6.conf.all.accept_ra=2

cat >> /etc/sysctl.conf << EOF
net.ipv4.ip_forward=1
net.ipv4.conf.all.forwarding=1
net.ipv6.conf.default.forwarding=1
net.ipv6.conf.all.forwarding=1
sysctl net.ipv6.conf.all.accept_ra=2
EOF

# Enable IPv6 Support per https://docs.docker.com/config/daemon/ipv6/
cat >> /etc/docker/daemon.json << EOF
{
  "ipv6": true,
  "fixed-cidr-v6": "fc00:172:17:0:0::/64"
}
EOF


# installing docker-engine vs docker
yum install docker-engine \
  --assumeyes

systemctl start docker
systemctl enable docker

# https://stackoverflow.com/questions/23111631/cannot-download-docker-images-behind-a-proxy
#mkdir /etc/systemd/system/docker.service.d
#cat >> /etc/systemd/system/docker.service.d/http-proxy.conf << EOF
#[Service]
#Environment="HTTP_PROXY=http://adc-proxy.oracle.com:80/"
#EOF

systemctl reload docker

systemctl status docker

uname -a
ip addr show

usermod -aG docker vagrant

docker run --name hello-world --rm hello-world
docker rmi hello-world

date +"%F %T"
echo "Exiting Docker Provisoning"
echo " "
