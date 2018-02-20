#!/usr/bin/env bash

echo "Entering Docker Provisoning"
date +"%F %T"

yum install docker-engine \
  --assumeyes

systemctl start docker
systemctl enable docker

cat >> /etc/docker/daemon.json << EOF
{
  "ipv6": true
}
EOF

systemctl reload docker

systemctl status docker

uname -a
ip addr show

usermod -aG docker vagrant

docker run --name hello-world hello-world
docker rm hello-world
docker rmi hello-world

date +"%F %T"
echo "Exiting Docker Provisoning"
echo " "
