#!/bin/bash

# kill swap:
while read id;
do
  swapoff /dev/zram"$id"
  echo $id > /sys/class/zram-control/hot_remove
  echo "zram swap id$id removed" | systemd-cat -t autozram -p info
done < /run/autozram/swap

# find all enabled zram swaps, we kill them all
for i in $(for j in $(cat /proc/swaps|grep /dev/zram); do echo $j|grep zram; done) do swapoff $i; done

# now kill all other drives:
while read id;
do
  umount /dev/zram"$id"
  echo $zram_drive > /sys/class/zram-control/hot_remove
  echo "zram drive id$id removed" | systemd-cat -t autozram -p info
done < /run/autozram/mounts
