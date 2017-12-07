# Layer2 forward

## Build

## Promiscuous mode
- [ ] Why DPDK applications enable promiscuous by default?

The l2fwd application enables promiscuous by default, let us comment out `rte_eth_promiscuous_enable` in `main.c` to disable promiscuous. Like this
```c
//rte_eth_promiscuous_enable(portid);
```
We need to disable promiscuous, because it is disturbing.

## Run
We have there pci devices bined to DPDK-compatible driver, which are 02:06.0, 02:07.0 and 02:08.0.
````
Network devices using DPDK-compatible driver
============================================
0000:02:06.0 '82545EM Gigabit Ethernet Controller (Copper) 100f' drv=igb_uio unused=vfio-pci
0000:02:07.0 '82545EM Gigabit Ethernet Controller (Copper) 100f' drv=igb_uio unused=vfio-pci
0000:02:08.0 '82545EM Gigabit Ethernet Controller (Copper) 100f' drv=igb_uio unused=vfio-pci
````
We use `02:06.0` to generate traffic by using pktgen-dpdk, while `02:07.0` and `02:08.0` to do layer2 forwarding.
Since one DPDK-compatible network device can only be used by one DPDK application, we need to blacklist `02:06.0` in l2fwd, do so to `02:07.0` and `02:08.0` in pktgen.

### Run l2fwd

```shell
cd $RTE_SDK/examples/l2fwd/
sudo ./build/l2fwd -c 0x3 -m 128 -b 02:06.0 -- -p 0x3

......

Initializing port 0... done:
Port 0, MAC address: 00:0C:29:E0:8B:D5

Initializing port 1... done:
Port 1, MAC address: 00:0C:29:E0:8B:DF

......
```

Current output of l2fwd is
````
Port statistics ====================================
Statistics for port 0 ------------------------------
Packets sent:                        0
Packets received:                    0
Packets dropped:                     0
Statistics for port 1 ------------------------------
Packets sent:                        0
Packets received:                    0
Packets dropped:                     0
Aggregate statistics ===============================
Total packets sent:                  0
Total packets received:              0
Total packets dropped:               0
====================================================
````

### Run pktgen-dpdk
```shell
cd /path-to-pktgen-dpdk/
./tools/dpdk-run.py default
Pktgen:/> set 0 dst mac 00:0C:29:E0:8B:D5
Pktgen:/> str
```
We set the dst mac of generated packetd to `00:0C:29:E0:8B:D5`, which is the mac of device `02:07.0` (port 0 in l2fwd).
Now l2fwd keeps receiving packets by port 0 (02:07.0) and forwarding out through port 1 (02:08.0).
Current output of l2fwd is
````
Port statistics ====================================
Statistics for port 0 ------------------------------
Packets sent:                        0
Packets received:              1131166
Packets dropped:                     0
Statistics for port 1 ------------------------------
Packets sent:                  1131166
Packets received:                    0
Packets dropped:                     0
Aggregate statistics ===============================
Total packets sent:            1131166
Total packets received:        1131166
Total packets dropped:               0
====================================================
````

We stop pktgen-dpdk and set the dst mac to `00:0C:29:E0:8B:DF` (port 1 in l2fwd), and start generating.
```shell
Pktgen:/> stp
Pktgen:/> set 0 dst mac 00:0C:29:E0:8B:DF
Pktgen:/> str
```
Current output of l2fwd is
````
Port statistics ====================================
Statistics for port 0 ------------------------------
Packets sent:                  7138496
Packets received:              1131166
Packets dropped:                     0
Statistics for port 1 ------------------------------
Packets sent:                  1131166
Packets received:              7138528
Packets dropped:                     0
Aggregate statistics ===============================
Total packets sent:            8269662
Total packets received:        8269694
Total packets dropped:               0
====================================================
````
Now, the l2fwd receives packets through port 1 and sends through port 0.

## Code analysis
