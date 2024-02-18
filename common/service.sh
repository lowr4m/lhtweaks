#!/system/bin/sh
# ----------------------
# Author: @lowrran_01  © 2024
# ----------------------

# mount point
MODDIR=${0%/*}

# Apply After Boot
wait_until_boot_complete() {
  while [[ "$(getprop sys.boot_completed)" != "1" ]]; do
    sleep 3
  done
}

wait_until_boot_complete

script_dir="$MODDIR/script"

# Make sure init is completed
sleep 15
####
rm -f $BASEDIR/flag/need_recuser

# GMS components
GMS="com.google.android.gms"
GC1="auth.managed.admin.DeviceAdminReceiver"
GC2="mdm.receivers.MdmDeviceAdminReceiver"
NLL="/dev/null"

# Disable collective device administrators
for U in $(ls /data/user); do
for C in $GC1 $GC2 $GC3; do
pm disable --user $U "$GMS/$GMS.$C" &> $NLL
done
done

# Add GMS to battery optimization
dumpsys deviceidle whitelist -com.google.android.gms &> $NLL

# =========
# Apply
# =========
sh $script_dir/Tweaks.sh