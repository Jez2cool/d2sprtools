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



cdv vendor/cm
echo "Fix eHRPD handoff http://review.cyanogenmod.org/#/c/27505/"
git fetch http://review.cyanogenmod.org/CyanogenMod/android_vendor_cm refs/changes/05/27505/2 && git cherry-pick FETCH_HEAD
cdb


cdv device/samsung/d2-common
echo "LTE toggle changes http://review.cyanogenmod.org/#/c/27571/"
git fetch http://review.cyanogenmod.org/CyanogenMod/android_device_samsung_d2-common refs/changes/71/27571/1 && git cherry-pick FETCH_HEAD
cdb

cdv packages/apps/Phone
echo "Support additional LTE modes http://review.cyanogenmod.org/#/c/27512/"
git fetch http://review.cyanogenmod.org/CyanogenMod/android_packages_apps_Phone refs/changes/12/27512/3 && git cherry-pick FETCH_HEAD
cdb

##### SUCCESS ####
SUCCESS=true
exit 0

