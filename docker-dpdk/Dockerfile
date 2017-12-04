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
