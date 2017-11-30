#!/bin/bash

sudo modprobe uio
sudo insmod ${RTE_SDK}/${RTE_TARGET}/kmod/igb_uio.ko
# If `devbind` report device is active, turn the device off by using ifdown
sudo ./dpdk-devbind.py -b igb_uio 02:06.0
