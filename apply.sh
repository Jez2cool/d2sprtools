#!/bin/bash

unset SUCCESS
on_exit() {
  if [ -z "$SUCCESS" ]; then
    echo "ERROR: $0 failed.  Please fix the above error."
    exit 1
  else
    echo "SUCCESS: $0 has completed."
    exit 0
  fi
}
trap on_exit EXIT

http_patch() {
  PATCHNAME=$(basename $1)
  curl -L -o $PATCHNAME -O -L $1
  cat $PATCHNAME |patch -p1
  rm $PATCHNAME
}

wget_patch() {
  PATCHNAME=$(basename $1)
  wget $1
  cat $PATCHNAME |patch -p1
  rm $PATCHNAME
}

# Change directory verbose
cdv() {
  cd $BASEDIR
  repo start auto $1
  echo
  echo "*****************************"
  echo "Current Directory: $1"
  echo "*****************************"
  cd $BASEDIR/$1
}

# Change back to base directory
cdb() {
  cd $BASEDIR
}

# Sanity check
if [ -d ../.repo ]; then
  cd ..
fi
if [ ! -d .repo ]; then
  echo "ERROR: Must run this script from the base of the repo."
  SUCCESS=true
  exit 255
fi

# Save Base Directory
BASEDIR=$(pwd)

# Abandon auto topic branch
repo abandon auto
set -e

################ Apply Patches Below ####################

cdv packages/apps/Settings
echo "Slider shortcuts http://review.cyanogenmod.org/#/c/27489/"
git fetch http://review.cyanogenmod.org/CyanogenMod/android_packages_apps_Settings refs/changes/89/27489/4 && git cherry-pick FETCH_HEAD
echo "re-enable LTE button http://review.cyanogenmod.org/#/c/27573/"
git fetch http://review.cyanogenmod.org/CyanogenMod/android_packages_apps_Settings refs/changes/73/27573/3 && git cherry-pick FETCH_HEAD
cdb

cdv frameworks/base
echo "Quicksettings changes http://review.cyanogenmod.org/#/c/27063/"
git fetch http://review.cyanogenmod.org/CyanogenMod/android_frameworks_base refs/changes/63/27063/20 && git cherry-pick FETCH_HEAD
echo "Quicksettings - framework http://review.cyanogenmod.org/#/c/27466/"
git fetch http://review.cyanogenmod.org/CyanogenMod/android_frameworks_base refs/changes/66/27466/4 && git cherry-pick FETCH_HEAD
echo "Re-enable LTE button - FW http://review.cyanogenmod.org/#/c/27572/"
git fetch http://review.cyanogenmod.org/CyanogenMod/android_frameworks_base refs/changes/72/27572/3 && git cherry-pick FETCH_HEAD
echo "QCom GPS HAL changes http://review.cyanogenmod.org/#/c/27778/"
git fetch http://review.cyanogenmod.org/CyanogenMod/android_frameworks_base refs/changes/78/27778/1 && git cherry-pick FETCH_HEAD
cdb

cdv frameworks/opt/telephony
echo "Fix NPE on call hangup http://review.cyanogenmod.org/#/c/27701/"
git fetch http://review.cyanogenmod.org/CyanogenMod/android_frameworks_opt_telephony refs/changes/01/27701/2 && git cherry-pick FETCH_HEAD
cdb

cdv device/samsung/d2-common
echo "GPS changes http://review.cyanogenmod.org/#/c/27814/"
git fetch http://review.cyanogenmod.org/CyanogenMod/android_device_samsung_d2-common refs/changes/14/27814/1 && git cherry-pick FETCH_HEAD
echo "Fix vold.fstab"
git fetch http://review.cyanogenmod.org/CyanogenMod/android_device_samsung_d2-common refs/changes/17/27817/1 && git cherry-pick FETCH_HEAD
cdb

cdv device/samsung/msm8960-common
echo "GPS changes, HAL http://review.cyanogenmod.org/#/c/27812/"
git fetch http://review.cyanogenmod.org/CyanogenMod/android_device_samsung_msm8960-common refs/changes/12/27812/3 && git cherry-pick FETCH_HEAD
cdb

cdv kernel/samsung/d2
echo "Revert splash screen"
git revert --no-edit aa80e6fc80207c9aaecbb42f4355d42862e27c2b
cdb

##### SUCCESS ####
SUCCESS=true
exit 0

