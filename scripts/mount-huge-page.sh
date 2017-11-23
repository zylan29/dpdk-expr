#!/bin/bash

sudo mkdir /mnt/huge2m
sudo mount -t hugetlbfs nodev /mnt/huge2m
sudo sh -c "/bin/echo 64 > /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages"                                                                      

sudo mkdir /mnt/huge1g
sudo mount -t hugetlbfs -o pagesize=1G nodev /mnt/huge1g/
sudo sh -c "/bin/echo 1 > /sys/devices/system/node/node0/hugepages/hugepages-1048576kB/nr_hugepages"
