# Hello DPDK world
## Build DPDK
Build DPDK from a fresh installed Ubuntu 17.10 system.

Download latest DPDK from dpdk.org

    wget http://fast.dpdk.org/rel/dpdk-17.11.tar.xz
    tar -xvf dpdk-17.11.tar.xz
    cd dpdk-17.11
Install required packages

    sudo apt-get install make gcc libnuma-dev libpcap-dev
Make from source

    make config T=x86_64-native-linuxapp-gcc
    sed -ri 's,(PMD_PCAP=).*,\1y,' build/.config
    make
## Setup RTE environment (optional)
Building dpdk applications needs the RTE_SDK and RTE_TARGET be set in the environment.
I would like to make dpdk system-wide available, which is an optional configuration.

    cd ..
    sudo mv dpdk-17.11 /opt/dpdk
Add the following lines to the end of /etc/profile

    export RTE_SDK=/path-to-dpdk
    export RTE_TARGET=build
then,

    source /etc/profile

# Configure large memory page
    sudo mkdir /mnt/huge2m
    sudo mount -t hugetlbfs nodev /mnt/huge2m
    sudo echo 64 > /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages

    sudo mkdir /mnt/huge1g
    sudo mount -t hugetlbfs -o pagesize=1G nodev /mnt/huge1g/
    sudo echo 2 > /sys/devices/system/node/node0/hugepages/hugepages-1048576kB/nr_hugepages

The 'sudo echo command' reports permission denied error, I have to edit the file by using vim instead.

# Hello world
Build helloworld application

    cd /path-to-dpdk/examples/helloworld
    make
Due to the permission issue, we use the superuser to run the application

    sudo ./build/helloworld -c f -n 2
The output is similar to

    hello from core 1
    hello from core 2
    hello from core 3
    hello from core 0
# TODO
- [ ] Enable vfio for non-privileged user
