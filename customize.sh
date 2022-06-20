PLMVER="$(cat $MODPATH/module.prop | grep version= | cut -d= -f2)"

ui_print ""
ui_print "   *****                                        *****"
ui_print "   *                                                *"
ui_print "   *                Pixel Launcher M                *"
ui_print ""
ui_print "                         $PLMVER"
ui_print ""
ui_print "   *                   #TeamFiles™                  *"
ui_print "   *                                                *"
ui_print "   *****                                        *****"
ui_print ""
sleep .5
ui_print "                         GitHub:"
ui_print ""
ui_print "       https://github.com/TeamFiles/PixelLauncherM"
ui_print ""
ui_print "                        Telegram:"
ui_print ""
ui_print "                     @PixelLauncherM"
ui_print ""
sleep .5

print() {
  ui_print "$@"
  ui_print ""
  sleep .1
}

logfile=/sdcard/PLM/log.txt
if [ -f $logfile ]; then
  rm -rf $logfile
fi
mkdir -p /sdcard/PLM
touch $logfile
echo "--------------------" >> $logfile
echo "Pixel Launcher M installation log file" >> $logfile
echo "--------------------" >> $logfile
echo "PLM VER: $PLMVER" >> $logfile
echo "MAGISK VER: $MAGISK_VER" >> $logfile
echo "MAGISK VER CODE: $MAGISK_VER_CODE" >> $logfile
echo "getprop dump:" >> $logfile
echo "$(getprop)" >> $logfile
echo "Begin event logger:" >> $logfile

print "    * Checking device compatibility..."

if [[ "$(ro.build.version.release)" == "13" ]]; then
  ANDROIDVER=13
  echo "selected android version $ANDROIDVER" >> $logfile
  print "    * Detected: Android 13"
  print "    * Status: Supported"
elif [ $API -eq 33 ]; then
  ANDROIDVER=13
  echo "selected android version $ANDROIDVER" >> $logfile
  print "    * Detected: Android 13"
  print "    * Status: Supported"
elif [ $API -eq 32 && "$(getprop ro.build.version.security_patch)" == "Tiramisu" ]; then
  ANDROIDVER=13
  echo "selected android version $ANDROIDVER" >> $logfile
  print "    * Detected: Android 13"
  print "    * Status: Supported"
elif [[ $API -eq 32 && "$(getprop ro.build.version.security_patch)" == "2022-06-05" ]]; then
  ANDROIDVER=12.1.j
  echo "selected android version $ANDROIDVER" >> $logfile
  print "    * Detected: Android 12.1/12L June Security Patch"
  print "    * Status: Supported"
elif [ $API -eq 32 ]; then
  ANDROIDVER=12.1.m
  echo "selected android version $ANDROIDVER" >> $logfile
  print "    * Detected: Android 12.1/12L Pre-June Patch"
  print "    * Status: Supported"
elif [ $API -eq 31 ]; then
  ANDROIDVER=12.0
  echo "selected android version $ANDROIDVER" >> $logfile
  print "    * Detected: Android 12.0"
  print "    * Status: Supported"
elif [ $API -le 30 ]; then
  echo "android version below 12, cancelling installation" >> $logfile
  print "    * Detected: Android 10 or lower"
  print "    * Status: Not supported"
  print "    * Cancelling installation..."
  sleep 2
  exit 1
else
  echo "didn't detect a version, cancelling installation" >> $logfile
  print "    * Something went wrong."
  print "    * Can't detect an Android version identifier."
  print "    * Cancelling installation..."
  sleep 2
  exit 1
fi

print "    * Installing..."

echo "started installer" >> $logfile

set_perm_recursive "$MODPATH" 0 0 0777 0755

echo "done init modpath perm" >> $logfile

tar -xf $MODPATH/install.tar.xz -C $MODPATH

echo "extracted install package" >> $logfile

set_perm_recursive "$MODPATH/temp" 0 0 0777 0755
set_perm_recursive "$MODPATH/system" 0 0 0777 0755
set_perm_recursive "$MODPATH/system/bin" 0 0 0777 0755 
set_perm_recursive "$MODPATH/system/product" 0 0 0777 0755 
set_perm_recursive "$MODPATH/system/product/app" 0 0 0777 0755
set_perm_recursive "$MODPATH/system/product/etc" 0 0 0777 0755
set_perm_recursive "$MODPATH/system/product/overlay" 0 0 0777 0755
set_perm_recursive "$MODPATH/system/product/priv-app" 0 0 0777 0755
set_perm_recursive "$MODPATH/system/system_ext" 0 0 0777 0755
set_perm_recursive "$MODPATH/system/system_ext/etc" 0 0 0777 0755
set_perm_recursive "$MODPATH/system/system_ext/priv-app" 0 0 0777 0755

echo "done init repeat perm" >> $logfile

#print "    * Running superrepack tool..."

#$MODPATH/temp/superrepack /dev/block/bootdevice/by-name/super

#echo "superrepack finished" >> $logfile

#print ""

print "   -------------------------25%------------------------"

#print "    * Continuing with PLM installation..."

sqlite=$MODPATH/temp/sqlite3

echo "set sqlite" >> $logfile

gms=/data/data/com.google.android.gms/databases/phenotype.db

echo "set gms db" >> $logfile

db_edit() {
  echo "db_edit running" >> $logfile
  type=$2
  val=$3
  name=$1
  shift
  shift
  shift
  for i in $@; do
    $sqlite $gms "DELETE FROM FlagOverrides WHERE packageName='$name' AND name='$i'"
    $sqlite $gms "INSERT INTO FlagOverrides(packageName, user, name, flagType, $type, committed) VALUES('$name', '', '$i', 0, $val, 0)"
    $sqlite $gms "UPDATE Flags SET $type='$val' WHERE packageName='$name' AND name='$i'"
  done
}

echo "db_edit set" >> $logfile

cp -f $MODPATH/temp/nlr.$ANDROIDVER.apk $MODPATH/system/product/priv-app/NexusLauncherRelease/NexusLauncherRelease.apk

echo "copied nlr version" >> $logfile

cp -f $MODPATH/temp/wps.$ANDROIDVER.apk $MODPATH/system/system_ext/priv-app/WallpaperPickerGoogleRelease/WallpaperPickerGoogleRelease.apk

echo "copied wps version" >> $logfile

mkdir -p /sdcard/PLM/Wallpapers

cp -r $MODPATH/temp/Wallpapers /sdcard/PLM/Wallpapers

cp -f $MODPATH/temp/README.txt /sdcard/PLM/README.txt

echo "moved files to /sdcard/PLM" >> $logfile

print "   -------------------------50%------------------------"

db_edit com.google.android.platform.device_personalization_services boolVal 1 "Echo__search_enable_app_search_tips" "Echo__search_enable_appsearch_tips_ranking_improvement" "Echo__search_enable_mdp_play_results" "Echo__search_enable_search_in_app_icon" "Echo__search_enable_static_shortcuts" "Echo__search_enable_superpacks_play_results" "Echo__search_enable_app_fetcher_v2" "Echo__search_enable_assistant_quick_phrases_settings" "Echo__smartspace_enable_battery_notification_parser" "Overview__enable_lens_r_overview_long_press" "Overview__enable_lens_r_overview_select_mode" "Overview__enable_lens_r_overview_translate_action" "Echo__smartspace_enable_doorbell" "Echo__smartspace_enable_earthquake_alert_predictor" "Echo__smartspace_enable_echo_settings" "Echo__smartspace_enable_light_predictor" "Echo__smartspace_enable_paired_device_predictor" "Echo__smartspace_enable_safety_check_predictor" "Echo__smartspace_enable_echo_unified_settings" "Echo__smartspace_enable_dark_launch_outlook_events" "Echo__smartspace_enable_step_predictor" "Echo__smartspace_enable_nap" "Echo__smartspace_enable_paired_device_connections" "Echo__smartspace_dedupe_fast_pair_notification" "Echo__smartspace_enable_nudge" "Echo__smartspace_enable_package_delivery" "Echo__smartspace_enable_outlook_events"

echo "db finished block 1" >> $logfile

db_edit com.google.android.platform.device_personalization_services boolVal 0 "SmartSelect__enable_smart_select_locked_bootloader_check"

echo "db finished block 2" >> $logfile

db_edit com.google.android.platform.launcher boolVal 1 "ENABLE_SMARTSPACE_ENHANCED" "ENABLE_WIDGETS_PICKER_AIAI_SEARCH"

echo "db finished block 3" >> $logfile

print "   -------------------------75%------------------------"

REMOVE=""

PL=$(find /system -name *Launcher* | grep -v overlay | grep -v Nexus | grep -v bin | grep -v "\.")
TR=$(find /system -name *Trebuchet* | grep -v overlay | grep -v "\.")
QS=$(find /system -name *QuickStep* | grep -v overlay | grep -v "\.")
LW=$(find /system -name *MiuiHome* | grep -v overlay | grep -v "\.")
TW=$(find /system -name *TouchWizHome* | grep -v overlay | grep -v "\.")
KW=$(find /system -name *Lawnchair* | grep -v overlay | grep -v "\.")

REMOVE="$REMOVE $PL $TR $QS $LW $TW $KW"

REMOVE="$(echo "$REMOVE" | tr ' ' '\n' | sort -u)"

REPLACE="$REMOVE"

echo "done set launcher removals" >> $logfile

rm -rf $MODPATH/install.tar.xz

echo "removed install package" >> $logfile

rm -rf $MODPATH/temp

echo "removed temp files" >> $logfile

rm -rf "/data/system/package_cache"

echo "clear package cache" >> $logfile

pm disable --user 0 "com.google.android.googlequicksearchbox" &>/dev/null

echo "disabled qsb" >> $logfile

pm enable --user 0 "com.google.android.googlequicksearchbox" &>/dev/null

echo "enabled qsb" >> $logfile

print "   ------------------------100%------------------------"

print "    * Done!"
print ""

echo "done" >> $logfile

print "    * (!)"
print "      PLEASE REBOOT RIGHT AWAY TO AVOID ERRORS!"
print "      (!)"
