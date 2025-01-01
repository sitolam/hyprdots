#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <grub_entry>"
    exit 1
fi

entry=$1

echo "Reboot to windows..."

echo "Are you sure you want to reboot to windows? [Y/n]"
read answer
case ${answer:0:1} in
    n|N )
        echo "Cancelled."
    ;;
    * )
        echo "Rebooting to Windows..."
        sleep 3
        sudo grub-reboot $entry && systemctl reboot
    ;;
esac