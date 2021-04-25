#!/bin/sh

VPS_IP=$1

# update the system
apt-get update
apt-get upgrade -y

# add Docker repository
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# add Kubernetes repository
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list && 

# add Helm repository
curl https://baltocdn.com/helm/signing.asc | apt-key add -
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list

# install tools
apt-get update
apt install docker-ce kubeadm kubelet kubernetes-cni helm -y

# start cluster
kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=$VPS_IP

# setup kubectl
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

# install networking model
kubectl create -f https://raw.githubusercontent.com/cilium/cilium/1.9.5/install/kubernetes/quick-install.yaml

# allow master to run pods
kubectl taint nodes --all node-role.kubernetes.io/master-

# install nginx
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install ingress-nginx ingress-nginx/ingress-nginx

# install certificate manager
helm repo add jetstack https://charts.jetstack.io
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.3.0 \
  --set installCRDs=true