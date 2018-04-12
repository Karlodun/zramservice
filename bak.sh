## runtime functions ##
function runtime_drop {
	# just in case the file isn't there
	touch /run/autozram/zram"$1"
	# drop line with variable if there
	cat /run/autozram/zram"$1" | grep -v $2 > /run/autozram/drivesmap
}

function runtime_set {
	# just in case the file isn't there
	touch /run/autozram/zram"$1"
	runtime_drop $2
	# append new value
	echo "zrive[$2]=$3" >> /run/autozram/zram"$1"
}

function runtime_get {
	export $(cat /run/autozram/drivesmap | grep $1)
}

function zrive {
    # hot adds and configs new zram drive
	# zrive needs:
	# 1. mount_point 2. filesystem 3. size
	# 4. max_mem_size 
	
	# get available pool from runtime
	runtime_get pool
	# check if pool is sufficient, exit if not
	if [pool < max_mem_size]
	then
        # maybe add some action to signal bad configuration
		return 0
	fi
    
    # add drive
	drive_id=$(cat /sys/class/zram-control/hot_add)

	# Set disksize, this value has nothing to do with real ram used!
	echo "$3"K > /sys/block/zram"$drive_id"/disksize
	# Set memory limit usage
	echo "$4"K > /sys/block/zram"$drive_id"/mem_limit

	# update runtime
    echo $(( mem_pool-$4 )) > /run/autozram/mem_pool  # new ram pool size
	runtime_set $1 $drive_id
	# create filesystem
	mkfs."$2" /dev/zram"$drive_id"
	# mount fs
	mount /dev/zram"$drive_id" $1
}

######################################

### ZRAM SWAP configuration ###
if [[zram_swap_on]]; then  # initiate zram swap if configured
  # calculate maximum ram usage by pool share and fixed value
  share_val=$(( mem_pool * swap_pool_share ))
  fix_val=$((swap_max_mem*1000))
  #check if they would fit into mem_pool
  share_val=$((share_val <= mem_pool ? share_val : mem_pool))
  fix_val=$((fix_val <= mem_pool ? fix_val : mem_pool))
  # choose highest possible value according to configuration
  zram_swap_limit=$(( share_val > fix_val ? share_val : fix_val))

  # hot add device and save id to runtime
  zram_swap=$(cat /sys/class/zram-control/hot_add)
  echo $zram_swap > /run/autozram/swap_id

  # Set disksize, this value has nothing to do with real ram used!
  echo "$mem_a"K > /sys/block/zram$(zram_swap)/disksize
  # Set memory limit usage
  echo "$zram_swap_limit" > /sys/block/zram"$zram_swap"/mem_limit

  $mem_pool=$(( mem_pool-zram_swap_limit))

  mkswap /dev/zram"$zram_swap" # Create swap filesystem
  swapon -p 100 /dev/zram"$zram_swap" # Switch the swap on
fi

## runtime functions ##
function runtime_drop {
	# just in case the file isn't there
	touch /run/autozram/drivesmap
	# drop line with variable if there
	cat /run/autozram/drivesmap | grep -v $1 > /run/autozram/drivesmap
}

function runtime_set {
	# just in case the file isn't there
	touch /run/autozram/drivesmap
	runtime_drop $1
	# append new value
	echo "zrive[$1]=$2" >> /run/autozram/drivesmap
}

function runtime_get {
	export $(cat /run/autozram/drivesmap | grep $1)
}

function zrive {
    # hot adds and configs new zram drive
	# zrive needs:
	# 1. mount_point 2. filesystem 3. size
	# 4. max_mem_size 
	
	# get available pool from runtime
	runtime_get pool
	# check if pool is sufficient, exit if not
	if [pool < max_mem_size]
	then
        # maybe add some action to signal bad configuration
		return 0
	fi
    
    # add drive
	drive_slot=$(cat /sys/class/zram-control/hot_add)

	# Set disksize, this value has nothing to do with real ram used!
	echo "$3"K > /sys/block/zram"$drive_slot"/disksize
	# Set memory limit usage
	echo "$4"K > /sys/block/zram"$drive_slot"/mem_limit

	# update runtime
    echo $(( mem_pool-$4 )) > /run/autozram/mem_pool  # new ram pool size
	runtime_set $1 $drive_slot
	# create filesystem
	mkfs."$2" /dev/zram"$drive_slot"
	# mount fs
	mount /dev/zram"$drive_slot" $1
}

