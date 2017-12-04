

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

# Build DPDK in docker container

## The Dockerfile
The Dockerfile for ubuntu 16.04 (modified from https://github.com/redhat-performance/docker-dpdk)
````
FROM ubuntu:16.04
MAINTAINER zylan29@outlook.com

LABEL RUN docker run -it --privileged -v /sys/bus/pci/drivers:/sys/bus/pci/drivers -v /sys/kernel/mm/hugepages:/sys/kernel/mm/hugepages -v /sys/devices/system/node:/sys/devices/system/node -v /dev:/dev --name NAME -e NAME=NAME -e IMAGE=IMAGE IMAGE

# Setup apt-get repos, use a fast source.

COPY ./sources.list /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y net-tools pciutils make gcc libnuma-dev libpcap-dev linux-headers-$(uname -r) git wget xz-utils

# Install DPDK support packages.

# Build DPDK and pktgen-dpdk for x86_64-native-linuxapp-gcc.
WORKDIR /root
COPY ./build_dpdk.sh /root/build_dpdk.sh
COPY ./dpdk-profile.sh /etc/profile.d/
RUN /root/build_dpdk.sh

# Defaults to a bash shell, you could put your DPDK-based application here.
CMD ["/bin/bash"]

````
## Build docker image

````
sudo docker build -t dpdk .
````

Please refer to https://github.com/redhat-performance/docker-dpdk for RHEL/CentOS systems.
However, you may need to modify the Dockerfile, build-dpdk.sh and dpdk-profile.sh scripts on your own to use new DPDK release.

## Run DPDK container
````
sudo docker run
````
