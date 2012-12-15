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

cdv frameworks/base
echo "SVDO support 1/2 http://review.cyanogenmod.org/#/c/28215/"
git fetch http://review.cyanogenmod.org/CyanogenMod/android_frameworks_base refs/changes/15/28215/1 && git cherry-pick FETCH_HEAD
echo "CellInfoLte - Turn off debug http://review.cyanogenmod.org/#/c/28269/"
git fetch http://review.cyanogenmod.org/CyanogenMod/android_frameworks_base refs/changes/69/28269/1 && git cherry-pick FETCH_HEAD
cdb

cdv frameworks/opt/telephony
echo "Psuedo-multipart SMS http://review.cyanogenmod.org/#/c/28175/"
git fetch http://review.cyanogenmod.org/CyanogenMod/android_frameworks_opt_telephony refs/changes/75/28175/1 && git cherry-pick FETCH_HEAD
echo "SVDO support 2/2 http://review.cyanogenmod.org/#/c/28216/"
git fetch http://review.cyanogenmod.org/CyanogenMod/android_frameworks_opt_telephony refs/changes/16/28216/1 && git cherry-pick FETCH_HEAD
echo "Fix CMDA/LTE Strength http://review.cyanogenmod.org/#/c/28237/"
git fetch http://review.cyanogenmod.org/CyanogenMod/android_frameworks_opt_telephony refs/changes/37/28237/1 && git cherry-pick FETCH_HEAD
cdb

cdv device/samsung/d2spr
echo "Enable psuedo-multipart SMS http://review.cyanogenmod.org/#/c/28176/"
git fetch http://review.cyanogenmod.org/CyanogenMod/android_device_samsung_d2spr refs/changes/76/28176/1 && git cherry-pick FETCH_HEAD
cdb

##### SUCCESS ####
SUCCESS=true
exit 0

