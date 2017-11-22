#!/bin/bash

sudo modprobe uio
sudo insmod ${RTE_SDK}/${RTE_TARGET}/kmod/igb_uio.ko
sudo ./dpdk-devbind.py -b igb_uio 02:06.0
