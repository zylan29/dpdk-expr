

# Install Docker

Official instruction to install docker-ce is： https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/#set-up-the-repository

Compact tutorial to install docker-ce is as follows:
````
sudo apt-get remove docker docker-engine docker.io
sudo apt-get update
sudo apt-get install -y \
    linux-image-extra-$(uname -r) \
    linux-image-extra-virtual
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install -y docker-ce
````

# Create docker image with DPDK

## The Dockerfile
````
apt-get install -y net-tools
apt-get install -y pciutils
apt-get install -y make gcc libnuma-dev libpcap-dev
apt-get install -y linux-headers-$(uname -r)

wget http://fast.dpdk.org/rel/dpdk-17.11.tar.xz
tar -xvf dpdk-17.11.tar.xz
cd dpdk-17.11

make config T=x86_64-native-linuxapp-gcc
sed -ri 's,(PMD_PCAP=).*,\1y,' build/.config
make
````
## Build docker image

````
sudo docker build -t dpdk .
````

http://jason.digitalinertia.net/exposing-docker-containers-with-sr-iov/

https://github.com/Rakurai/pipework

https://github.com/docker/libnetwork/blob/master/docs/macvlan.md
