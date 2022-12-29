##master node should  be 2c cpu and 4gb memory(ram)

###n this is for all nodes(master $ slaves)
sudo apt update

sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

 sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF 

sudo sysctl --system
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
# for containerd
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

sudo apt update
sudo apt install -y containerd.io
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd

#
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"

sudo apt update
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl


#start and enable kubelet service
sudo systemctl daemon-reload
sudo systemctl start kubelet
sudo systemctl enable kubelet.service

 #############for mastern Node##################
sudo su -
# initialize kubernetes master execution below coommand
 kubeadm init

# if you want to init kubernetes on public  endpoinyt (not recommended in real time ). you can use below option replace public-ip with actual public ip of your  kube master node (recommonded to use
elastic (create and assign elastic ip  to master node and use that elastic ip Below .  Replace port with   6443

kubeadm  init --control-plane-endpoint "PUBLIC_IP:PORT"
 kubeadm  init --control-plane-endpoint "13.233.236.146:6443"

if Error
sudo kubeadm init --cri-socket /run/containerd/containerd.sock
# exit as root user & execute as normal user
exit

# run these command use the kubernetes in  normal ubuntu user 
 mkdir -p $HOME/.kube 
 sudo cp -i  /etc/kubernetes/admin.conf $HOME/.kube/config
 sudo chown $(id -u): $(id -g) $HOME/.kube/config

# to verify kubernets
kubectl get node -o wide  -n kube-system

# you will notice from the previous command, that all the pods are runniing except one : 'core-dns'.
##for resolving sthis we will installl a # pod network. To install the weaVE pod network ,run the following command:
# network build ip address and create connection between pods
# search networking adon  

kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml  ##  i  use weave network ,,,this network require some port open

kubectl get nodes -o wide

# generate token for slave
kubectl token create --print-join-command  ## it provide token with command

############----for slave----#############

#use that token command for connect to the master node