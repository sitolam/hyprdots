#!/usr/bin/env bash
#|---/ /+-----------------------------------+---/ /|#
#|--/ /-| Script to install flatpaks (user) |--/ /-|#
#|-/ /--| Prasanth Rangan                   |-/ /--|#
#|/ /---+-----------------------------------+/ /---|#

baseDir=$(dirname "$(realpath "$0")")
scrDir=$(dirname "$(dirname "$(realpath "$0")")")

source "${scrDir}/global_fn.sh"
if [ $? -ne 0 ]; then
    echo "Error: unable to source global_fn.sh..."
    exit 1
fi
chk_list "aurhlpr" "${aurList[@]}"

use_default="--noconfirm --needed"
aurhPkg=(flutter-bin android-sdk android-sdk-build-tools android-sdk-cmdline-tools-latest android-platform android-sdk-platform-tools)

if [[ ${#aurhPkg[@]} -gt 0 ]]; then
    "${aurhlpr}" ${use_default} -Sy "${aurhPkg[@]}"
fi


sudo chown -R $USER:$(groups ${USER} | awk '{print $1}') /opt/android-sdk

echo 'export ANDROID_HOME=/opt/android-sdk' >> $HOME/.zshrc
echo 'export PATH=$PATH:$ANDROID_HOME/platform-tools' >> $HOME/.zshrc
echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk' >> $HOME/.zshrc

yes | flutter doctor --android-licenses