#!/bin/bash

################################################################################
#
#  build_dpdk.sh
#
#             - Build DPDK and pktgen-dpdk for 
#
#  Usage:     Adjust variables below before running, if necessary.
#
#  MAINTAINER:  jeder@redhat.com
#
#
################################################################################

################################################################################
#  Define Global Variables and Functions
################################################################################

DPDKTAR=dpdk-17.11.tar.xz
URL=http://fast.dpdk.org/rel/$DPDKTAR
BASEDIR=/root
VERSION=17.11
PACKAGE=dpdk
DPDKROOT=$BASEDIR/$PACKAGE-$VERSION
CONFIG=x86_64-native-linuxapp-gcc


# Download/Build DPDK
cd $BASEDIR
wget $URL
tar -xvf "$DPDKTAR"
cd $DPDKROOT
make config T=$CONFIG
sed -ri 's,(PMD_PCAP=).*,\1y,' build/.config
make
make install

source /etc/profile.d/dpdk-profile.sh

# Download/Build pktgen-dpdk
URL=git://dpdk.org/apps/pktgen-dpdk
BASEDIR=/root
PACKAGE=pktgen-dpdk
PKTGENROOT=$BASEDIR/$PACKAGE
cd $BASEDIR
git clone $URL

# Silence compiler info message
sed -i '/Wwrite-strings$/ s/$/ -Wno-unused-but-set-variable/' $DPDKROOT/mk/toolchain/gcc/rte.vars.mk
cd $PKTGENROOT
make
