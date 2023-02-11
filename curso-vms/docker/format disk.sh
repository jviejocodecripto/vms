https://opentechtips.com/how-to-create-nat-ed-subnets-in-hyper-v/#7_Routing_between_Subnets_on_the_same_Hyper-V_host

https://www.wikihow.com/Enable-IP-Routing-on-Windows-10
https://support.tetcos.com/support/solutions/articles/14000098272-how-to-enable-ip-forwarding-in-windows-to-perform-emulation-using-netsim-?fbclid=IwAR2CG0v7_dyGBzYoHFC5DrVakbMjF19CSwItYh6QyrJUY8maWSigw2AcA-8

New-VMSwitch -SwitchName "NATSwitch" -SwitchType Internal
New-NetIPAddress -IPAddress 192.168.0.1 -PrefixLength 24 -InterfaceAlias "vEthernet (NATSwitch)"
New-NetNAT -Name "NATNetwork" -InternalIPInterfaceAddressPrefix 192.168.0.0/24

https://getlabsdone.com/how-to-configure-hyper-v-virtual-switches/

New-NetIPAddress -InterfaceAlias 'vEthernet (vSwitchIntMUN)' -IPAddress 192.168.13.1 -PrefixLength 24
Connect-VMNetworkAdapter -VMName mun-dc01 -SwitchName vSwitchIntMUN

lsblk -fm
sudo fdisk /dev/sda
sudo mkfs.ext4 /dev/sda1
sudo nano /etc/fstab   
/dev/sda1       /backup         ext4    default         0       0


parted /dev/vdb mkpart primary ext4 0% 100%

#!/bin/bash
############################################################################
# This script simply formats a block device and mounts it to the data
# directory in a very safe manner by checking that the block device is
# completely empty
#
############################################################################
set -eu

if [ $# -ne 2 ]
then
	echo "";
	echo "    Usage: ./${0} <block_device> <mount_directory>";
	echo;
	echo "    Example: ./${0} /dev/vdb /data";
	echo;
	echo "    To figure out the block devices on the machine use lsblk command";
	echo "";
	exit 1;
fi

set -x
BLOCK_DEVICE_PATH="${1}"
MOUNT_TO_DIR="${2}"

## SAFETY CHECK ###########################################################
# Check if ${BLOCK_DEVICE_PATH} is mounted, if yes, then exit
if [[ $(/bin/mount | grep -q "${BLOCK_DEVICE_PATH}") ]]; then
  echo "BLOCK DEVICE ${BLOCK_DEVICE_PATH} ALREADY MOUNTED"
  exit 1;
fi

## SAFETY CHECK ###########################################################
if [[ $(/sbin/blkid ${BLOCK_DEVICE_PATH}) ]]; then
  echo "BLOCK DEVICE ALREADY INITIALIZED, WILL NOT PROCEED WITH SCRIPT";
  exit 1;
fi

## CREATE PARTITION TABLE AND CREATE PARTITION
parted --script ${BLOCK_DEVICE_PATH} mklabel gpt
parted --script ${BLOCK_DEVICE_PATH} mkpart primary ext4 0% 100%

## NEEDED FOR lsblk TO REFRESH
echo "Sleeping 5 seconds"
sleep 5;

## PARTITIONNAME WITHOUR '/dev' 
PARTITION_NAME=`lsblk -l ${BLOCK_DEVICE_PATH} | tail -1 | awk '{print $1}'`

## SAFETY CHECK ###########################################################
if [[ ${#PARTITION_NAME} -ne 4 ]]; then
  echo "EXITING SINCE [$PARTITION_NAME] DOES NOT CONTAIN 4 CHARACTERS";
  exit 1;
fi;

## Format it as ext4
mkfs.ext4 "/dev/$PARTITION_NAME"

## Create a mount directory at /data if does not exist
mkdir -p "${MOUNT_TO_DIR}"

# Mount it in /etc/fstab
UUID_STRING=`blkid -o export /dev/$PARTITION_NAME | grep "^UUID"`
echo -e "\n$UUID_STRING ${MOUNT_TO_DIR} ext4 defaults,nofail 0 0" >> /etc/fstab

# Run mount -a
mount -a

# TO UNDO WHAT THE SCRIPT HAS DONE
# PLEASE DO NOT COMMENT THIS OUT, ONLY SERVES FOR DOCUMENTATION
# USE ONLY WHEN YOU ARE SURE WHAT YOU ARE DOING
# umount /dev/vdb1
# wipefs -a /dev/vdb1
# parted /dev/vdb rm 1
# wipefs -a /dev/vdb