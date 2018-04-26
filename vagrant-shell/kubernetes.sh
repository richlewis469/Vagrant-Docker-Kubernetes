#!/usr/bin/env bash

echo "Entering Kubernetes Provisoning"
date +"%F %T"
# Setup per https://docs.oracle.com/cd/E52668_01/E88884/html/ol_about_kubernetes.html

yum-config-manager --enable ol7_addons

#docker login container-registry.oracle.com

systemctl start firewalld
systemctl enable firewalld

iptables  -P FORWARD ACCEPT
ip6tables -P FORWARD ACCEPT

iptables-save > /etc/sysconfig/iptables
ip6tables-save > /etc/sysconfig/ip6tables

firewall-cmd --add-masquerade --permanent
firewall-cmd --add-port=10250/tcp --permanent
firewall-cmd --add-port=8472/udp --permanent
firewall-cmd --add-port=6443/tcp --permanent

systemctl restart firewalld

lsmod | grep br_netfilter
if [[ $? -ne 0 ]]; then
  modprobe br_netfilter
  echo "br_netfilter" > /etc/modules-load.d/br_netfilter.conf
fi

if [ ! -f /etc/sysctl.d/k8s.conf ]; then
cat >> /etc/sysctl.d/k8s.conf << EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
/sbin/sysctl -p /etc/sysctl.d/k8s.conf
else
  sed -i 's/tables = 0/tables = 1/' /etc/sysctl.d/k8s.conf /etc/sysctl.d/k8s.conf
fi

setenforce Permissive
sed -i 's/=enforcing/=permissive/g' /etc/selinux/config /etc/selinux/config

yum install kubeadm --assumeyes

echo "--Setup the environment variables--"
source /vagrant-share/vagrant-docker/env-vars.sh

docker login -u $OCR_VAR_LOGIN -p $OCR_VAR_PASSWORD container-registry.oracle.com

kubeadm-setup.sh up

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
export KUBECONFIG=$HOME/.kube/config
# echo 'export KUBECONFIG=$HOME/.kube/config' >> $HOME/.bashrc
echo "source <(kubectl completion bash)" >> ~/.bashrc

sleep 180 # Sleep 3m to allow container creation.
kubectl get pods -n kube-system
kubeadm token list
kubectl get nodes
kubectl describe nodes
kubectl get pods

#Kubernetes with Proxy server
#cat >> /etc/systemd/system/docker.service.d/http-proxy.conf << EOF
#[Service]
#Environment="HTTP_PROXY=http://adc-proxy.oracle.com:80"
#Environment="HTTPS_PROXY=https://adc-proxy.oracle.com:80"
#EOF
#systemctl daemon-reload; systemctl restart docker

#kubectl run hello-world --image=nginxdemos/hello --port=8080
kubectl run hello-world --image=nginxdemos/hello
#kubectl expose deployment hello-world --type="LoadBalancer"
kubectl expose deployment hello-world
kubectl get services hello-world

date +"%F %T"
echo "Exiting Kubernetes Provisoning"
echo " "
