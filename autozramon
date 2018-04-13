#!/bin/bash

# load zram module with 0 devices, we'll hot add for each configured one
modprobe zram num_devices=0
# get total amount of system RAM
mem_a=$(grep MemTotal /proc/meminfo | grep -E --only-matching '[[:digit:]]+')

# prepare config (should make config file error prone):
mem_usable=0
mem_pool_share=0

# read config and calculate memory pool available for all automatic zram drives
while IFS=: read -r var val
do
    case "$var" in
    mem_reserved )
        # calculate usable pool in kb
        $mem_usable=$(( 0 < val && mem_a > val*2000 ? mem_a - val*1000 : mem_a / 2 ))
        ;;
    mem_pool_share )
        $mem_pool_share=$(( 0 < val && 100 > val ? val*10 : 1000 ))
        ;;
done < /etc/autozram.conf
mem_pool=$(( mem_usable * mem_pool_share ))

# creating drives
while IFS=: read -r var val
do
    case "$var" in
    drive )
      drive_name=$val
    mount )
      mount_path=$val
    fs )
      file_system=$val
    size )
      # makes no sense, if drive is more than 4 times of available pool
      # if drive size is too big, negative or NaN, size is set to twice of available pool at that moment
      drive_size=$(( 0 < val && mem_pool*4 > val ? val*1000 : mem_pool*2))
    max_mem )
      _max_mem=$(( 0 < val ? val*1000 : 0))
    max_pool_share )
      _max_pool_share=$(( val > 100 ? 1000 : $val*10 ))
    init )
      if ![[ -d $mount_point || "swap"==$val ]]; then  # abort if no mount point or not swap
        echo "no mount point found, drive $_drive_name" | systemd-cat -t autozram -p warning
        break
      fi
      
      # calculate maximum ram usage by pool share and fixed value
      share_val=$(( mem_pool * _max_pool_share ))
      fix_val=$(( _max_mem*1000 ))
      #check if they would fit into mem_pool and fix in needed
      share_val=$((share_val <= mem_pool ? share_val : mem_pool))
      fix_val=$((fix_val <= mem_pool ? fix_val : mem_pool))
      # choose highest possible value according to configuration
      max_mem_size=$(( share_val > fix_val ? share_val : fix_val))

      drive_id=$(cat /sys/class/zram-control/hot_add)  # hot add device
      echo "$drive_size"K > /sys/block/zram"$drive_id"/disksize  # set size and initiate
      echo "$max_mem_size"K > /sys/block/zram"$drive_id"/mem_limit  # limit memory usage
      $mem_pool=$(( mem_pool-max_mem_size ))  # update mem_pool

      case "$val" in
      none )
        unset drive_name mount_point file_system drive_size drive_max_mem drive_max_share      
        ;;
      swap )
        mkswap /dev/zram"$drive_id" # Create swap filesystem
        swapon -p 100 /dev/zram"$drive_id" # Switch the swap on
        echo "$drive_id" >> /run/autozram/swap  # save to runtime
        echo 'zram swap ready' | systemd-cat -t autozram -p info
        ;;
      mount )
        mkfs."$file_system" /dev/zram"$drive_id"
        mount /dev/zram"$drive_id" "$mount_path"
        echo "$drive_id" >> /run/autozram/mounted  # save to runtime
        echo "drive $_drive_name ready" | systemd-cat -t autozram -p info
        ;;
    }
done < /etc/autozram.conf