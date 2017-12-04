
# Test pktgen-dpdk
## Build pktgen-dpdk
````
git clone git://dpdk.org/apps/pktgen-dpdk
cd pktgen-dpdk
sed -i '/Wwrite-strings$/ s/$/ -Wno-unused-but-set-variable/' $DPDKROOT/mk/toolchain/gcc/rte.vars.mk
make
````
## New DPDK container

````
docker run -it --privileged -v /sys/bus/pci/drivers:/sys/bus/pci/drivers -v /sys/kernel/mm/hugepages:/sys/kernel/mm/hugepages -v /sys/devices/system/node:/sys/devices/system/node -v /dev:/dev -v /tmp/virtio:/tmp/virtio dpdk
````

## Run test-pmd inside of container
We run testpmd inside the container.
After the container launched, build test-pmd application.
````
source /etc/profile.d/dpdk-profile.sh
cd $RTE_SDK/app/test-pmd
make
````
then run it
````
./testpmd -l 0-1 -n 1 --socket-mem 512 \
--vdev 'eth_vhost0,iface=/tmp/virtio/sock0' --vdev 'eth_vhost1,iface=/tmp/virtio/sock1' \
--file-prefix=test --no-pci \
-- -i --forward-mode=io --auto-start
````

## Run pktgen outside of container
Open a new terminal, then change directory to the top of this tutorial. The `scripts/virtio.cfg` file configures the  pktgen.
````
cp scripts/virtio.cfg $PKTGEN/cfg/
cd $PKTGEN
./tools/dpdk-run.py virtio
Pktgen:/> set 0 count 1000
Pktgen:/> set 1 count 2000
Pktgen:/> str
````
Note: It seems not workable with some hugepages settings, such as `2048 * 2M`, but it works with `4 * 1G`.
- [ ] Why it only works with hugepages `4 * 1G`, not `2048 * 2M`?

## Checkout the result
Change to the terminal of container.
Show port statistics, the output is
````
testpmd> show port stats all

  ######################## NIC statistics for port 0  ########################
  RX-packets: 1000       RX-missed: 0          RX-bytes:  72960
  RX-errors: 0
  RX-nombuf:  0
  TX-packets: 2000       TX-errors: 0          TX-bytes:  183360

  Throughput (since last show)
  Rx-pps:           20
  Tx-pps:           41
  ############################################################################

  ######################## NIC statistics for port 1  ########################
  RX-packets: 2000       RX-missed: 0          RX-bytes:  183360
  RX-errors: 0
  RX-nombuf:  0
  TX-packets: 256        TX-errors: 744        TX-bytes:  15360

  Throughput (since last show)
  Rx-pps:           41
  Tx-pps:            5
  ############################################################################
````
- [ ] Some `Tx-errors` in the output, why?
