#!/system/bin/sh
# This script will be executed in late_start service mode

# Variable
MG=/sys/kernel/mm

sleep 10
#==========
# Kernel Tweaks
#==========

for kernel in proc/sys/kernel
	do
	echo '1' > ${kernel}/timer_migration
	echo '0' > ${kernel}/ftrace_dump_on_oops
done

#==========
# Kernel Panic
#==========

for kernel in /proc/sys/kernel
	do
    echo '0' > ${kernel}/panic
    echo '0' > ${kernel}/panic_on_oops
    echo '0' > ${kernel}/panic_on_warn
    echo '0' > ${kernel}/panic_on_rcu_stall
    echo '0' > ${kernel}/softlockup_panic
    echo '0' > ${kernel}/nmi_watchdog
done

#==========

for module in /sys/module
	do
    echo '0' > ${module}/kernel/parameters/panic
    echo '0' > ${module}/kernel/parameters/panic_on_warn
    echo '0' > ${module}/kernel/parameters/pause_on_oops
    echo '0' > ${module}/kernel/panic_on_rcu_stall
done

#==========
# Excessive Log
#==========

for kernel in /sys/kernel
	do
    echo 'N' > ${kernel}/debug/debug_enabled
    echo 'N' > ${kernel}/debug/sched_debug
    echo '0' > ${kernel}/tracing/tracing_on
done

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

for kernel in /proc/sys/kernel
	do
    echo '0 0 0 0' > ${kernel}/printk
	echo 'off' > ${kernel}/printk_devkmsg
done

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

for queue in /sys/block/*/queue
	do
	echo '0' > ${queue}/iostats
	echo '0' > ${queue}/rq_affinity
	echo '2' > ${queue}/nomerges
	echo '128' > ${queue}/read_ahead_kb
	echo '64' > ${queue}/nr_requests
done

#==========
# Adreno Tweaks for battery life
#==========

for gpu in /sys/class/kgsl/kgsl-3d0
	do
    echo "0" > ${gpu}/thermal_pwrlevel
    echo "0" > ${gpu}/throttling 
    echo "0" > ${gpu}/max_pwrlevel
    echo "0" > ${gpu}/perfcounter
    echo "0" > ${gpu}/force_clk_on             
    echo "0" > ${gpu}/force_bus_on
    echo "1" > ${gpu}/bus_split  
    echo "0" > ${gpu}/force_no_nap
    echo "0" > ${gpu}/force_rail_on 
    echo "80" > ${gpu}/idle_timer
	echo "0" > ${gpu}/snapshot/snapshot_crashdumper
done

#==========
# Power Saving Workqueues
#==========

for module in /sys/module
	do
	chmod 644 ${module}/workqueue/parameters/power_efficient
	sleep 1
	echo 'Y' > ${module}/workqueue/parameters/power_efficient
done

#==========
# CPUSET (POWER SAVING)
#==========

for cpu in /dev/cpuset
	do
	echo "0-1" > ${cpu}/background/cpus
	echo "0-1" > ${cpu}/background/effective_cpus
	echo "0-3" > ${cpu}/system-background/cpus
	echo "0-3" > ${cpu}/system-background/effective_cpus
	echo "0-7" > ${cpu}/camera-daemon/cpus
	echo "0-7" > ${cpu}/camera-daemon/effective_cpus
	echo "0-1" > ${cpu}/audio-app/cpus
	echo "0-7" > ${cpu}/top-app/cpus
	echo "0-7" > ${cpu}/top-app/effective_cpus
	echo "0-3" > ${cpu}/foreground/boost/cpus
done

#==========
# RAM Tweak
#==========

for VM in /proc/sys/vm
	do
	echo '60' > $VM/dirty_ratio
	echo '5' > $VM/dirty_background_ratio
	echo '1000' > $VM/dirty_expire_centisecs
	echo '3000' > $VM/dirty_writeback_centisecs
	echo '0' > $VM/page-cluster
	echo '60' > $VM/stat_interval
	echo '100' > $VM/swappiness
	echo '0' > $VM/laptop_mode
	echo '50' > $VM/vfs_cache_pressure
	echo '0' > $VM/panic_on_oom
done

#==========
# Reduce CPU usage
#==========

for kernel in proc/sys/kernel
	do
	echo '10' > ${kernel}/perf_cpu_time_max_percent
	echo '0' > ${kernel}/sched_schedstats
done

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

#==========
# Bye Script
#==========
su -lp 2000 -c "cmd notification post -S bigtext -t '✔ LHMods ✔' 'Tag' 'The module was applied correctly, now you can enjoy a better experience 😁.'"

exit 0
