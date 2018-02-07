#!/usr/bin/env bash

echo "Entering Docker Provisoning"
date +"%F %T"

yum install docker-engine \
  --assumeyes

systemctl start docker
systemctl enable docker

systemctl status docker

uname -a
ip addr show

docker pull oraclelinux:7.4
docker images --all
docker run --name docker-test oraclelinux:7.4 \
  /bin/bash -c "echo 'Begin Docker Run'; uname -a; ip addr show; date; echo 'End Docker Run'"
docker ps --all
docker rm  docker-test
docker rmi oraclelinux:7.4

date +"%F %T"
echo "Exiting Docker Provisoning"
echo " "
