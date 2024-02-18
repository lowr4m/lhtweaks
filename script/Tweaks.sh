#!/system/bin/sh
# This script will be executed in late_start service mode

#==========
# Variables
KE=/proc/sys/kernel
MD=/sys/module
KL=/sys/kernel
KG=/sys/class/kgsl/kgsl-3d0
VM=/proc/sys/vm
ST=/dev/cpuset
MG=/sys/kernel/mm/lru_gen
BL=/sys/block

#==========
# Kernel Panic
#==========

    echo '0' > $KE/panic
    echo '0' > $KE/panic_on_oops
    echo '0' > $KE/panic_on_warn
    echo '0' > $KE/panic_on_rcu_stall
    echo '0' > $KE/softlockup_panic
    echo '0' > $KE/nmi_watchdog
    echo '0' > $MD/kernel/parameters/panic
    echo '0' > $MD/kernel/parameters/panic_on_warn
    echo '0' > $MD/kernel/parameters/pause_on_oops
    echo '0' > $MD/kernel/panic_on_rcu_stall

#==========
# Excessive Log
#==========

    echo 'N' > $KL/debug/debug_enabled
    echo 'N' > $KL/debug/sched_debug
    echo '0' > $KL/tracing/tracing_on

#==========
# CRC
#==========

    echo '0' > $ML/mmc_core/parameters/use_spi_crc
    echo 'N' > $ML/mmc_core/parameters/removable
    echo 'N' > $ML/mmc_core/parameters/crc

#==========
# Kernel Debugging (thx to KTSR)
#==========
for i in debug_mask log_level* debug_level* *debug_mode edac_mc_log* enable_event_log *log_level* *log_ue* *log_ce* log_ecn_error snapshot_crashdumper seclog* compat-log *log_enabled tracing_on mballoc_debug; do
    for o in $(find /sys/ -type f -name "$i"); do
      echo 0 > "$o"
    done
done

#==========
# System Log
#==========

    pm disable com.android.traceur

#==========
# Printk (thx to KNTD-reborn)
#==========

    echo '0 0 0 0' > $KE/printk
    chmod 644 $KL/printk_mode/printk_mode
    echo '0' > $KL/printk_mode/printk_mode
    chmod 644 $MD/printk/parameters/ignore_loglevel
    echo 'Y' > $MD/printk/parameters/ignore_loglevel
    chmod 644 $MD/printk/parameters/pid
	echo 'N' $MD/printk/parameters/pid
	chmod 644 $MD/printk/parameters/time
	echo 'N' > $MD/printk/parameters/time
	echo 'off' > $KE/printk_devkmsg

#==========
# More Useless Services
#==========

	pm disable com.google.android.gms/.chimera.GmsIntentOperationService
	pm disable com.google.android.gms/com.google.android.gms.mdm.receivers.MdmDeviceAdminReceiver
	pm disable com.qualcoom.wfd.service
	pm disable com.quicinc.voice.activation
	pm disable com.qualcomm.qti.devicestatisticsservice
	pm disable com.miui.powerkeeper/.powerchecker.PowerCheckerService

#==========
# I/O
#==========

	echo '0' > $BL/sda/queue/iostats
	echo '0' > $BL/sda/queue/rq_affinity
	echo '128' > $BL/sda/queue/read_ahead_kb
	echo '128' > $BL/sda/queue/nr_requests
	
	echo '0' > $BL/sdb/queue/iostats
	echo '0' > $BL/sdb/queue/rq_affinity
	echo '128' > $BL/sdb/queue/read_ahead_kb
	echo '128' > $BL/sdb/queue/nr_requests

	echo '0' > $BL/sdc/queue/iostats
	echo '0' > $BL/sdc/queue/rq_affinity
	echo '128' > $BL/sdc/queue/read_ahead_kb
	echo '128' > $BL/sdc/queue/nr_requests

	echo '0' > $BL/sdd/queue/iostats
	echo '0' > $BL/sdd/queue/rq_affinity
	echo '128' > $BL/sdd/queue/read_ahead_kb
	echo '128' > $BL/sdd/queue/nr_requests

	echo '0' > $BL/sde/queue/iostats
	echo '0' > $BL/sde/queue/rq_affinity
	echo '128' > $BL/sde/queue/read_ahead_kb
	echo '128' > $BL/sde/queue/nr_requests
	
	echo '0' > $BL/sdf/queue/iostats
	echo '0' > $BL/sdf/queue/rq_affinity
	echo '128' $BL/sdf/queue/read_ahead_kb
	echo '128' $BL/sdf/queue/nr_requests

#==========
# Adreno Tweaks for battery life
#==========

    echo "0" > $KG/thermal_pwrlevel
    echo "0" > $KG/throttling 
    echo "0" > $KG/max_pwrlevel
    echo "0" > $KG/perfcounter
    echo "0" > $KG/force_clk_on             
    echo "0" > $KG/force_bus_on
    echo "1" > $KG/bus_split  
    echo "0" > $KG/force_no_nap
    echo "0" > $KG/force_rail_on 
    echo "80" > $KG/idle_timer

#==========
# Disable Adreno crashdumper
#==========

    echo "0" > $KG/snapshot/snapshot_crashdumper

#==========
# Power Saving Workqueues
#==========

	chmod 644 $MD/workqueue/parameters/power_efficient
	echo 'Y' > $MD/workqueue/parameters/power_efficient

#==========
# CPUSET (POWER SAVING)
#==========

	echo "0-1" > $ST/background/cpus
	echo "0-1" > $ST/background/effective_cpus
	echo "0-3" > $ST/system-background/cpus
	echo "0-3" > $ST/system-background/effective_cpus
	echo "0-7" > $ST/camera-daemon/cpus
	echo "0-7" > $ST/camera-daemon/effective_cpus
	echo "0-1" > $ST/audio-app/cpus
	echo "0-7" > $ST/top-app/cpus
	echo "0-7" > $ST/top-app/effective_cpus
	echo "0-3" > $ST/foreground/boost/cpus

#==========
# RAM Tweak
#==========

	echo '60' > $VM/dirty_ratio
	echo '10' > $VM/dirty_background_ratio
	echo '1000' > $VM/dirty_expire_centisecs
	echo '3000' > $VM/dirty_writeback_centisecs
	echo '0' > $VM/page-cluster
	echo '60' > $VM/stat_interval
	echo '100' > $VM/swappiness
	echo '0' > $VM/laptop_mode
	echo '50' > $VM/vfs_cache_pressure
	echo '0' > $VM/panic_on_oom


#==========
# Reduce CPU usage
#==========

	echo '10' > $KE/perf_cpu_time_max_percent

#==========
# Scheduler Tweaks
#==========

	echo '0' > $KE/sched_schedstats

#==========
# Check if kernal have Muti-Gen LRU and tweak it
#==========

if [ -d "$MG" ]; then
    echo 'y' > $MG/enabled
    echo '5000' > $MG/min_ttl_ms
fi

#==========
# ENABLE WRITE-AHEAD LOGGING (WAL)
#==========

	echo "PRAGMA journal_mode=WAL;" | sqlite3 database.db

#==========
# RELAX THE SYNCHRONIZATION MODE
#==========

	echo "PRAGMA synchronous=OFF;" | sqlite3 database.db

#==========
# COMPACT THE DATABASE
#==========

	echo "VACUUM;" | sqlite3 database.db

#==========
# Stop Xiaomi perf service
#==========

	stop vendor.perfservice
	stop miuibooster
	stop vendor.miperf

#==========

# Stop Qualcomm perfd
	stop perfd 2>/dev/null
	
#==========

#==========
# Bye Script
#==========
	su -lp 2000 -c "cmd notification post -S bigtext -t '✔ LHMods ✔' 'Tag' 'The module was applied correctly, now you can enjoy a better experience 😁.'"

exit 0
