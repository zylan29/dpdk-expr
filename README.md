# Step by step DPDK experiments

This tutorial aims to build an experimental environment of DPDK.
By following this tutorial, you can
1. Build DPDK test enviroment in **ONE VM**.
2. Make concrete understanding of DPDK.
3. Valid the correctness of DPDK applications.

However, it is **NOT** for performance purpose.

1. Preparation
1. [Hello DPDK world](markdown/1-hello-dpdk.md)
1. [Bind NIC to uio driver](markdown/2-bind-nic-uio.md)
1. [Apply DPDK in a docker container](markdown/3-dpdk-in-container.md)
1. [Test pktgen-dpdk](markdown/4-pktgen-dpdk.md)
1. Layer 2 forward
1. Layer 3 forward

# Enviroment
My test environment is
````
Guest OS: Ubuntu 16.04 server
Hypervisor: VMware workstation
Host OS: Windows 10
````
This tutorial works according to my exprience, and should also apply to other virtual machines, such as rhel and centos, which may need some customization.
