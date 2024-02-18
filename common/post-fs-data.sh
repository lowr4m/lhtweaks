#!/system/bin/sh
# THIS SCRIPT WILL BE EXECUTED IN POST-FS-DATA MODE
MODDIR=${0%/*}
# ----------------------
# Author: @lowrran_01
# ----------------------
# SURFACE FLINGER SFANALYSIS
SF=system/bin/surfaceflinger

# $1:file_node $2:owner $3:group $4:permission $5:secontext
__set_perm() {
    chown $2:$3 $1
    chmod $4 $1
    chcon $5 $1
}

rm -f $MODDIR/$SF

if [ -f "$MODDIR/flag/need_recuser" ]; then
    rm -f $MODDIR/flag/need_recuser
    true >$MODDIR/disable
    exit 0
else
    true >$MODDIR/flag/need_recuser
fi

# maybe timing issue
sleep 1
$MODDIR/system/bin/patchelf --add-needed libsfanalysis.so /$SF --output $MODDIR/$SF
__set_perm $MODDIR/$SF 0 0 0755 "$(ls -Zl /$SF | cut -d' ' -f5)"
# fstrim
  fstrim -v /system >/dev/null 2>&1
  SYSTEM_EXIT=$?
  fstrim -v /data >/dev/null 2>&1
  DATA_EXIT=$?
  fstrim -v /cache >/dev/null 2>&1
  CACHE_EXIT=$?
  fstrim -v /product >/dev/null 2>&1
  PRODUCT_EXIT=$?
  
# GMS
{
GMS0="\"com.google.android.gms"\"
STR1="allow-unthrottled-location package=$GMS0"
STR2="allow-ignore-location-settings package=$GMS0"
STR3="allow-in-power-save package=$GMS0"
STR4="allow-in-data-usage-save package=$GMS0"
NULL="/dev/null"
}

{
find /data/adb/* -type f -iname "*.xml" -print |
while IFS= read -r XML; do
for X in $XML; do
if grep -qE "$STR1|$STR2|$STR3|$STR4" $X 2> $NULL; then
sed -i "/$STR1/d;/$STR2/d;/$STR3/d;/$STR4/d" $X
fi
done
done
}

# STOP SERVICES WITHOUT SUPERUSER PRIVILEGES
stop logd
stop traced
stop tcpdump
stop cnss_diag
stop idd-logreader
stop idd-logreadermain

# Doze setup services
pm disable com.google.android.gms/.update.SystemUpdateActivity 
pm disable com.google.android.gms/.update.SystemUpdateService 
pm disable com.google.android.gms/.update.SystemUpdateService
pm disable com.google.android.gms/.update.SystemUpdateService
pm disable com.google.android.gms/.update.SystemUpdateService
pm disable com.google.android.gsf/.update.SystemUpdateActivity 
pm disable com.google.android.gsf/.update.SystemUpdatePanoActivity 
pm disable com.google.android.gsf/.update.SystemUpdateService 
pm disable com.google.android.gsf/.update.SystemUpdateService
pm disable com.google.android.gsf/.update.SystemUpdateService
pm disable --user 0 com.google.android.gms/.phenotype.service.sync.PhenotypeConfigurator

# DISABLE XIAOMI PROGRAM DEBUGGING
resetprop sys.miui.ndcd off

# Power Efficient
chmod 644 $MD/workqueue/parameters/power_efficient
sleep 1
echo 'Y' > $MD/workqueue/parameters/power_efficient

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

sleep 1
# Sync before execute to avoid crashes
sync
