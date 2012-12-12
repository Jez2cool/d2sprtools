#!/bin/bash
#


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

cdv frameworks/base
echo "SVDO support 1/2 http://review.cyanogenmod.org/#/c/27998/"
git fetch http://review.cyanogenmod.org/CyanogenMod/android_frameworks_base refs/changes/98/27998/2 && git cherry-pick FETCH_HEAD
echo "Lockscreen long keypress 1/2 http://review.cyanogenmod.org/#/c/28053/"
git fetch http://review.cyanogenmod.org/CyanogenMod/android_frameworks_base refs/changes/53/28053/3 && git cherry-pick FETCH_HEAD
cdb

cdv frameworks/opt/telephony
echo "Psuedo-multipart SMS http://review.cyanogenmod.org/#/c/28055/"
git fetch http://review.cyanogenmod.org/CyanogenMod/android_frameworks_opt_telephony refs/changes/55/28055/1 && git cherry-pick FETCH_HEAD
cdb

cdv device/samsung/d2spr
echo "Enable psuedo-multipart SMS http://review.cyanogenmod.org/#/c/28056/"
git fetch http://review.cyanogenmod.org/CyanogenMod/android_device_samsung_d2spr refs/changes/56/28056/1 && git cherry-pick FETCH_HEAD
cdb

cdv frameworks/opt/telephony
echo "Fix NPE on call hangup http://review.cyanogenmod.org/#/c/27701/"
git fetch http://review.cyanogenmod.org/CyanogenMod/android_frameworks_opt_telephony refs/changes/01/27701/2 && git cherry-pick FETCH_HEAD
echo "SVDO support 2/2 http://review.cyanogenmod.org/#/c/27997/"
git fetch http://review.cyanogenmod.org/CyanogenMod/android_frameworks_opt_telephony refs/changes/97/27997/1 && git cherry-pick FETCH_HEAD
cdb

cdv packages/apps/Settings
echo "Lockscreen long keypress 2/2 http://review.cyanogenmod.org/#/c/28051/"
git fetch http://review.cyanogenmod.org/CyanogenMod/android_packages_apps_Settings refs/changes/51/28051/2 && git cherry-pick FETCH_HEAD
cdb

##### SUCCESS ####
SUCCESS=true
exit 0

