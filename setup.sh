##########################################################################################
#
# Magisk Module Installer Script
#
##########################################################################################
##########################################################################################
#
# Instructions:
#
# 1. Place your files into system folder (delete the placeholder file)
# 2. Fill in your module's info into module.prop
# 3. Configure and implement callbacks in this file
# 4. If you need boot scripts, add them into common/post-fs-data.sh or common/service.sh
# 5. Add your additional or modified system properties into common/system.prop
#
##########################################################################################
#!/sbin/sh

# Config Vars
# Set to true if you do *NOT* want Magisk to mount
# any files for you. Most modules would NOT want
# to set this flag to true
SKIPMOUNT=false

# Set to true if you need to load system.prop
PROPFILE=true

# Set to true if you need post-fs-data script
POSTFSDATA=true

# Set to true if you need late_start service script
LATESTARTSERVICE=true

# Info Print
# Set what you want to be displayed on header of installation process

info_print() {
  awk '{print}' "$MODPATH"/smooth_banner
}

# List all directories you want to directly replace in the system
# Check the documentations for more info why you would need this

# Construct your list in the following format
# This is an example
REPLACE_EXAMPLE="
/system/app/Youtube
/system/priv-app/SystemUI
/system/priv-app/Settings
/system/framework
"

# Construct your own list here
REPLACE="
"

ui_print "----------------------------------"
ui_print "█ █▄░█ █▀ ▀█▀ ▄▀█ █░░ █░░ █ █▄░█ █▀▀ ░ ░ ░"
ui_print "█ █░▀█ ▄█ ░█░ █▀█ █▄▄ █▄▄ █ █░▀█ █▄█ ▄ ▄ ▄"
ui_print "----------------------------------"


api=$(getprop ro.build.version.sdk)
aarch=$(getprop ro.product.cpu.abi | awk -F- '{print $1}')
androidRelease=$(getprop ro.build.version.release)
dm=$(getprop ro.product.model)
socet=$(getprop ro.soc.model)
device=$(getprop ro.product.vendor.device)
magisk=$(magisk -c)
percentage=$(cat /sys/class/power_supply/battery/capacity)
memTotal=$(free -m | awk '/^Mem:/{print $2}')
rom=$(getprop ro.build.display.id)
romversion=$(getprop ro.vendor.build.version.incremental)
version="1.2.5"

ui_print ""
ui_print "----------------------------------"
ui_print "█ █▄░█ █▀▀ █▀█ █▀█ █▀▄▀█ ▄▀█ ▀█▀ █ █▀█ █▄░█"
ui_print "█ █░▀█ █▀░ █▄█ █▀▄ █░▀░█ █▀█ ░█░ █ █▄█ █░▀█"
ui_print "----------------------------------"
sleep 0.1
ui_print " --> Android Version: $androidRelease"
sleep 0.1
ui_print " --> Api: $api"
sleep 0.1
ui_print " --> SOC: $mf$soc$socet"
sleep 0.1
ui_print " --> CPU AArch: $aarch"
sleep 0.1
ui_print " --> Device: $dm ($device)"
sleep 0.1
ui_print " --> Battery charge level: $percentage%"
sleep 0.1
ui_print " --> Device total RAM: $memTotal MB"
sleep 0.1
ui_print " --> Magisk: $magisk"
sleep 0.1
ui_print " "
ui_print " --> Version tweaks: $version"
ui_print "----------------------------------"
ui_print ""

sleep 1

# INIT 

init_main() {
  # The following is the default implementation: extract $ZIPFILE/system to $MODPATH
  # Extend/change the logic to whatever you want
  $BOOTMODE || abort "[!] Smooth tweaks cannot be installed in recovery, flash to magisk."

  ui_print " "
  ui_print "----------------------------------"
  ui_print "█▀▀ ▀▄▀ ▀█▀ █▀█ ▄▀█ █▀▀ ▀█▀ █ █▄░█ █▀▀"
  ui_print "██▄ █░█ ░█░ █▀▄ █▀█ █▄▄ ░█░ █ █░▀█ █▄█"
  ui_print ""
  ui_print "█▀▄▀█ █▀█ █▀▄ █░█ █░░ █▀▀"
  ui_print "█░▀░█ █▄█ █▄▀ █▄█ █▄▄ ██▄"
  ui_print ""
  ui_print "█▀▀ █ █░░ █▀▀ █▀"
  ui_print "█▀░ █ █▄▄ ██▄ ▄█"
  ui_print "----------------------------------"
  
  unzip -o "$ZIPFILE" 'system/*' -d $MODPATH >&2
  
  ui_print ""
  sleep 1

  ui_print "----------------------------------"
  ui_print "█▀▄ █▀█ █▄░█ █▀▀"
  ui_print "█▄▀ █▄█ █░▀█ ██▄"
  ui_print "----------------------------------"
  
  ui_print ""
  sleep 1
  
  SCRIPT_PARENT_PATH="$MODPATH/script"
  SCRIPT_NAME="Tweaks.sh"
  SCRIPT_PATH="$SCRIPT_PARENT_PATH/$SCRIPT_NAME"

  ui_print "----------------------------------"
  ui_print "█▀▄ █▀█ █▄░█ █▀▀"
  ui_print "█▄▀ █▄█ █░▀█ ██▄"
  ui_print "----------------------------------"

  ui_print ""
  sleep 1

  ui_print "----------------------------------"
  ui_print "█▄░█ █▀█ ▀█▀ █▀▀ █▀"
  ui_print "█░▀█ █▄█ ░█░ ██▄ ▄█"
  ui_print "----------------------------------"
  ui_print ""
  ui_print "❗ Reboot is required"
  sleep 1.25

  ui_print "----------------------------------"
  ui_print "█▀█ █▀▀ █▄▄ █▀█ █▀█ ▀█▀"
  ui_print "█▀▄ ██▄ █▄█ █▄█ █▄█ ░█░"
  ui_print ""
  ui_print "▀█▀ █▀█   █▀▀ █ █▄░█ █ █▀ █░█ ░"
  ui_print "░█░ █▄█   █▀░ █ █░▀█ █ ▄█ █▀█ ▄"
  ui_print "----------------------------------"
}

# Set permissions

set_permissions() {
  # The following is the default rule, DO NOT remove
  set_perm_recursive $MODPATH 0 0 0755 0644
  set_perm_recursive $SCRIPT_PATH root root 0777 0755
  set_perm_recursive $MODPATH/script 0 0 0755 0755
  set_perm_recursive $MODPATH/bin 0 0 0755 0755
  set_perm_recursive $MODPATH/system 0 0 0755 0755
  set_perm_recursive $MODPATH/system/bin 0 0 0755 0755
  set_perm_recursive $MODPATH/system/vendor 0 0 0755 0755
  set_perm_recursive $MODPATH/system/vendor/etc 0 0 0755 0755
}

# CHANGE THE PERMISSIONS OF THE DEVFREQ FILES
chmod 0444 /sys/class/devfreq/soc:qcom,cpu-llcc-ddr-bw/min_freq
chmod 0444 /sys/class/devfreq/soc:qcom,cpu-llcc-ddr-bw/max_freq
chmod 0444 /sys/class/devfreq/soc:qcom,cpu-cpu-llcc-bw/min_freq
chmod 0444 /sys/class/devfreq/soc:qcom,cpu-cpu-llcc-bw/max_freq

# Set what you want to display when installing your module

print_modname() {
  ui_print "*******************************"
  ui_print "       SQLITE3 INSTALLER       "
  ui_print "*******************************"
}

# Copy/extract your module files into $MODPATH in on_install.

on_install() {
  # The following is the default implementation: extract $ZIPFILE/system to $MODPATH
  # Extend/change the logic to whatever you want
  ui_print "- Extracting module files"
  unzip -o "$ZIPFILE" 'system/*' -d $MODPATH >&2

  set_bindir
}

# Only some special files require specific permissions
# This function will be called after on_install is done
# The default permissions should be good enough for most cases

set_permissions() {
  # The following is the default rule, DO NOT remove
  set_perm_recursive $MODPATH 0 0 0755 0755

  # Here are some examples:
  # set_perm_recursive  $MODPATH/system/lib       0     0       0755      0644
  # set_perm  $MODPATH/system/bin/app_process32   0     2000    0755      u:object_r:zygote_exec:s0
  # set_perm  $MODPATH/system/bin/dex2oat         0     2000    0755      u:object_r:dex2oat_exec:s0
  # set_perm  $MODPATH/system/lib/libart.so       0     0       0644
}

# You can add more functions to assist your custom script code
set_bindir() {
  local bindir=/system/bin
  local xbindir=/system/xbin

  # Check for existence of /system/xbin directory.
  if [ ! -d /sbin/.magisk/mirror$xbindir ]; then
    # Use /system/bin instead of /system/xbin.
    mkdir -p $MODPATH$bindir
    mv $MODPATH$xbindir/sqlite3 $MODPATH$bindir
    rmdir $MODPATH$xbindir
    xbindir=$bindir
 fi

 ui_print "- Installed to $xbindir"
}

# GMS
ui_print "- Patching XML files"
{
GMS0="\"com.google.android.gms"\"
STR1="allow-in-power-save package=$GMS0"
STR2="allow-in-data-usage-save package=$GMS0"
NULL="/dev/null"
}
ui_print "- Searching default XML files"
SYS_XML="$(
SXML="$(find /system_ext/* /system/* /product/* \
/vendor/* -type f -iname '*.xml' -print)"
for S in $SXML; do
if grep -qE "$STR1|$STR2" $ROOT$S 2> $NULL; then
echo "$S"
fi
done
)"

PATCH_SX() {
for SX in $SYS_XML; do
mkdir -p "$(dirname $MODPATH$SX)"
cp -af $ROOT$SX $MODPATH$SX
 ui_print "  Patching: $SX"
sed -i "/$STR1/d;/$STR2/d" $MODPATH/$SX
done

# Merge patched files under /system dir
for P in product vendor; do
if [ -d $MODPATH/$P ]; then
 ui_print "- Moving files to module directory"
mkdir -p $MODPATH/system/$P
mv -f $MODPATH/$P $MODPATH/system/
fi
done
}

# Search and patch any conflicting modules (if present)
# Search conflicting XML files
MOD_XML="$(
MXML="$(find /data/adb/* -type f -iname "*.xml" -print)"
for M in $MXML; do
if grep -qE "$STR1|$STR2" $M; then
echo "$M"
fi
done
)"

PATCH_MX() {
 ui_print "- Searching conflicting XML"
for MX in $MOD_XML; do
MOD="$(echo "$MX" | awk -F'/' '{print $5}')"
 ui_print "  $MOD: $MX"
sed -i "/$STR1/d;/$STR2/d" $MX
done
}

# Find and patch conflicting XML
PATCH_SX && PATCH_MX

# Additional add-on for check gms status
ADDON() {
 ui_print "- Inflating add-on file"
mkdir -p $MODPATH/system/bin
mv -f $MODPATH/gmsc $MODPATH/system/bin/gmsc
}

FINALIZE() {
 ui_print "- Finalizing installation"

# Clean up
 ui_print "  Cleaning obsolete files"
find $MODPATH/* -maxdepth 0 \
! -name 'module.prop' \
! -name 'post-fs-data.sh' \
! -name 'service.sh' \
! -name 'system' \
-exec rm -rf {} \;

# Settings dir and file permission
 ui_print "  Settings permissions"
set_perm_recursive $MODPATH 0 0 0755 0755
set_perm $MODPATH/system/bin/gmsc 0 2000 0755
}

# Copy/extract your module files into $MODPATH in on_install.
on_install() {
    $BOOTMODE || abort "! SfAnalysis cannot be installed in recovery."
    [ $ARCH == "arm64" ] || abort "! SfAnalysis ONLY support arm64 platform."

    ui_print "- Extracting module files"
    unzip -o "$ZIPFILE" -x 'META-INF/*' -d $MODPATH >/dev/null
}

# Only some special files require specific permissions
# This function will be called after on_install is done
# The default permissions should be good enough for most cases
set_permissions() {
    __set_perm $MODPATH/system/lib64/libsfanalysis.so 0 0 0644 u:object_r:system_lib_file:s0
    __set_perm $MODPATH/system/bin/patchelf 0 0 0755 u:object_r:system_file:s0
}


