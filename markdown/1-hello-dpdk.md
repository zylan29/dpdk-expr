# Hello DPDK world
## Build DPDK
Build DPDK from a fresh installed Ubuntu (VM) system.

Download latest DPDK from dpdk.org
```shell
wget http://fast.dpdk.org/rel/dpdk-17.11.tar.xz
tar -xvf dpdk-17.11.tar.xz
cd dpdk-17.11
```
Install required packages
```shell
sudo apt-get install make gcc libnuma-dev libpcap-dev
```
Make from source
```shell
make config T=x86_64-native-linuxapp-gcc
sed -ri 's,(PMD_PCAP=).*,\1y,' build/.config
make
```
## Setup RTE environment (optional)
Building dpdk applications needs the RTE_SDK and RTE_TARGET be set in the environment.
I would like to make dpdk system-wide available, which is an optional configuration.
```shell
cd ..
sudo mv dpdk-17.11 /opt/dpdk
```
Add the following lines to the end of /etc/profile
```shell
export RTE_SDK=/path-to-dpdk
export RTE_TARGET=build
```
then,
```shell
source /etc/profile
```

# Configure hugepages
```shell
sudo mkdir /mnt/huge2m
sudo mount -t hugetlbfs nodev /mnt/huge2m
sudo sh -c "/bin/echo 64 > /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages"                                                                              
sudo mkdir /mnt/huge1g
sudo mount -t hugetlbfs -o pagesize=1G nodev /mnt/huge1g/
sudo sh -c "/bin/echo 1 > /sys/devices/system/node/node0/hugepages/hugepages-1048576kB/nr_hugepages"
```

The `sudo` has to cover whole redirection in order it can be completely executed under root.

The hugepage sizes that a CPU supports can be determined from the CPU flags on Intel architecture. If pse exists, 2M hugepages are supported; if pdpe1gb exists, 1G hugepages are supported.
For 64-bit applications, it is recommended to use 1 GB hugepages if the platform supports them.
We can automatically mount hugepages when OS booted.
1. Edit file `/etc/default/grub`, and append `"default_hugepagesz=1GB hugepagesz=1G hugepages=4"` to `GRUB_CMDLINE_LINUX_DEFAULT`,
1. Do `sudo update-grub`,
1. Edit file `/etc/fstab` , and add a new line `nodev /dev/hugepages hugetlbfs defaults 0 0` to the end of the file,
1. Finally `reboot`.

# Hello world
Build helloworld application
```shell
cd /path-to-dpdk/examples/helloworld
make
```
Due to the permission issue, we use the superuser to run the application
```shell
sudo ./build/helloworld
```
The output is similar to
```
hello from core 1
hello from core 2
hello from core 3
hello from core 0
```

# Code in detail

The helloworld code is really simple.

```c
static int
lcore_hello(__attribute__((unused)) void *arg)
{
	unsigned lcore_id;
	lcore_id = rte_lcore_id();
	printf("hello from core %u\n", lcore_id);
	return 0;
}

int
main(int argc, char **argv)
{
	int ret;
	unsigned lcore_id;

    /* initialize RTE(RunTime Enviroment) */
	ret = rte_eal_init(argc, argv);
	if (ret < 0)
		rte_panic("Cannot init EAL\n");

	/* call lcore_hello() on every slave lcore */
	RTE_LCORE_FOREACH_SLAVE(lcore_id) {
		rte_eal_remote_launch(lcore_hello, NULL, lcore_id);
	}

	/* call it on master lcore too */
	lcore_hello(NULL);

	rte_eal_mp_wait_lcore();
	return 0;
}
```

`rte_eal_init` --> `RTE_LCORE_FOREACH_SLAVE`

`rte_eal_remote_launch`

`rte_eal_mp_wait_lcore`
