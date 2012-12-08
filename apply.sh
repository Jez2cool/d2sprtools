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
echo "ADB over network http://review.cyanogenmod.org/#/c/27910/"
git fetch http://review.cyanogenmod.org/CyanogenMod/android_packages_apps_Settings refs/changes/10/27910/1 && git cherry-pick FETCH_HEAD
cdb

cdv frameworks/base
echo "Slider shortcuts - framework http://review.cyanogenmod.org/#/c/27466/"
git fetch http://review.cyanogenmod.org/CyanogenMod/android_frameworks_base refs/changes/66/27466/4 && git cherry-pick FETCH_HEAD
echo "Status bar clock and date http://review.cyanogenmod.org/#/c/27795/"
git fetch http://review.cyanogenmod.org/CyanogenMod/android_frameworks_base refs/changes/95/27795/2 && git cherry-pick FETCH_HEAD
echo "ADB over network - FW http://review.cyanogenmod.org/#/c/27909/"
git fetch http://review.cyanogenmod.org/CyanogenMod/android_frameworks_base refs/changes/09/27909/1 && git cherry-pick FETCH_HEAD
cdb

cdv frameworks/opt/telephony
echo "Fix NPE on call hangup http://review.cyanogenmod.org/#/c/27701/"
git fetch http://review.cyanogenmod.org/CyanogenMod/android_frameworks_opt_telephony refs/changes/01/27701/2 && git cherry-pick FETCH_HEAD
cdb

cdv kernel/samsung/d2
echo "Revert splash screen"
git revert --no-edit aa80e6fc80207c9aaecbb42f4355d42862e27c2b
cdb

##### SUCCESS ####
SUCCESS=true
exit 0

