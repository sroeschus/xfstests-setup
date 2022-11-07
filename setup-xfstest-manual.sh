#!/bin/bash -xv
~
if [ "$#" -ne 2 ]; then
        echo "Usage: setup-lvm-xfstests.sh <directory> <device>"
        exit 1
fi
~
XFSTESTS=$1
DEVICE=$2                                                                                                67,1          Bot

mkdir /mnt/test > /dev/null 2>&1
mkdir /mnt/scratch > /dev/null 2>&1

pvcreate -ff $DEVICE
vgcreate -f vg0 $DEVICE
lvcreate -L 53g -n lv0 vg0
for i in $(seq 1 10)
do
        lvcreate -L 10g -n lv$i vg0
done

SCRATCH_MNT=/mnt/scratch
SCRATCH_DEV_POOL=
TEST_DIR=/mnt/test
TEST_DEV=/dev/mapper/vg0-lv0

mkfs.btrfs -f $TEST_DEV

for i in $(seq 1 9)
do
        SCRATCH_DEV_POOL="/dev/mapper/vg0-lv$i $SCRATCH_DEV_POOL"
done
LOGWRITES_DEV="/dev/mapper/vg0-lv10"
PERF_CONFIGNAME="shr"

mount /dev/mapper/vg0-lv0 /mnt/test
