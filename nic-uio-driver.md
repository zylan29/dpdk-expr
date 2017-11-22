# Bind NIC to uio driver
Show current network device drivers
````
cd ${RTE_SDK}/${RTE_TARGET}/usertools/
./dpdk-devbind.py --status
````
The output looks like
````
Network devices using DPDK-compatible driver
============================================
<none>

Network devices using kernel driver
===================================
0000:02:01.0 '82545EM Gigabit Ethernet Controller (Copper) 100f' if=ens33 drv=e1000 unused= *Active*
0000:02:06.0 '82545EM Gigabit Ethernet Controller (Copper) 100f' if=ens38 drv=e1000 unused=
````
Probe uio driver

    sudo modprobe uio
    sudo insmod ${RTE_SDK}/${RTE_TARGET}/kmod/igb_uio.ko
    sudo ./dpdk-devbind.py -b igb_uio 02:06.0
The output looks like
````
Network devices using DPDK-compatible driver
============================================
0000:02:06.0 '82545EM Gigabit Ethernet Controller (Copper) 100f' drv=igb_uio unused=uio_pci_generic

Network devices using kernel driver
===================================
0000:02:01.0 '82545EM Gigabit Ethernet Controller (Copper) 100f' if=ens33 drv=e1000 unused=igb_uio,uio_pci_generic *Active*
````

`uio_pci_generic` is another valid DPDK-compatible driver. However, I fail to bind NIC to in my VM, so I use `igb_uio` instead. From my experience, uio_pci_generic is workable in physical machines.

# Fix virtual enviroment issue

The command
````
cd $RTE_SDK/examples/l2fwd
sudo ./build/l2fwd -- -p 0x1
````
reports

    EAL: Error reading from file descriptor 13: Input/output error
It is an issue comes with the VMWare workstation virtual machines, due to the VMware emulated e1000 device doesn't support INTX_DISABLE flag.
Patch to fix the issue can be found from http://dpdk.org/dev/patchwork/patch/7203/.
Since the patch does not apply to DPDK-17.11 directly.
I have to modify `lib/librte_eal/linuxapp/igb_uio/igb_uio.c` manually according to the patch, and re-make from source, then re-bind the NIC to igb_uio driver.

The new patch for DPDK-17.11 is
````
diff --git a/lib/librte_eal/linuxapp/igb_uio/igb_uio.c b/opt/dpdk/lib/librte_eal/linuxapp/igb_uio/igb_uio.c
index a3a98c1..1c06a5a 100644
--- a/lib/librte_eal/linuxapp/igb_uio/igb_uio.c
+++ b/opt/dpdk/lib/librte_eal/linuxapp/igb_uio/igb_uio.c
@@ -34,6 +34,7 @@
 #include <linux/version.h>
 #include <linux/slab.h>

+#include <asm/hypervisor.h>
 #include <rte_pci_dev_features.h>

 #include "compat.h"
@@ -274,7 +275,8 @@ igbuio_pci_enable_interrupts(struct rte_uio_pci_dev *udev)
 #endif
        /* fall back to INTX */
        case RTE_INTR_MODE_LEGACY:
-               if (pci_intx_mask_supported(udev->pdev)) {
+               /*  VMware emulated e1000 doesn't support INTX_DISABLE flag */
+               if (pci_intx_mask_supported(udev->pdev) || x86_hyper == &x86_hyper_vmware) {
                        dev_dbg(&udev->pdev->dev, "using INTX");
                        udev->info.irq_flags = IRQF_SHARED | IRQF_NO_THREAD;
                        udev->info.irq = udev->pdev->irq;
````
