#!/bin/bash
#=================================================
# Call: test-setup.sh <device-name>
#=================================================
if [ "$#" -ne 1 ]; then
        echo "Usage: tests-setup.sh <device>"
        exit 1
fi

DIR=$(pwd)/xfstests
DEVICE=$1
KERNEL_VERSION=$(uname -r | sed -r 's/([0-9]+)/0000\1/g; s/0*([0-9]{4})/\1/g' | sed 's/\.//g' | cut -c 1-8)

# Install packages for xfstests.
dnf install -y git fb-fwdproxy-config lvm2 \
               systemd passwd bc attr btrfs-progs fio hostname \
               perl xfsprogs e2fsprogs openssh-server bash iproute \
               busybox acl attr automake bc dbench dump e2fsprogs fio \
               gawk gcc indent libtool lvm2 make psmisc quota sed \
               xfsdump xfsprogs libacl-devel libaio-devel libuuid-devel \
               xfsprogs-devel btrfs-progs-devel python36 sqlite liburing-devel \
               libcap-devel

# Set proxy for git.
fwdproxy-config git --git-command > gitfwdenv

# Install xfstests.
git $(cat gitfwdenv) clone https://github.com/kdave/xfstests.git

# Create local config.
./setup-xfstest.sh ${DIR} ${DEVICE}

# Build xfstests.
cd xfstests
# Switch to older commit for 5.6 or earlierkernel.
# if [[ $(expr $KERNEL_VERSION + 0) -le 50006 ]]; then
#   git switch -c 5.6-test 'b2d552fbca6c9af18f603b845a688609479ebb3d'
# fi
make
make install
cd ..

# Create test users.
useradd -m fsgqa
groupadd fsgqa
useradd 123456-fsgqa
useradd fsgqa2

# Install packages for btrfs-progs.
mkdir ~/progs
dnf install -y asciidoc xmlto e2fsprogs-devel libblkid-devel libzstd-devel \
               lzo-devel libudev-devel

# Clone repository.
git $(cat gitfwdenv) clone https://github.com/kdave/btrfs-progs.git

# Make program
cd ~/btrfs-progs
./autogen.sh
./configure --prefix=/root/progs --disable-zoned --disable-python --disable-documentation
make
make install
cd ..

echo "Tests have been installed."
echo "Don't forget to update the PATH to use the newly compiled btrs-prog binaries."
echo "      export PATH=$(pwd)/progs/bin:\${PATH}"
echo "You can now invoke the tests with..."
echo "      cd xfstests"
echo "      ./check 'btrfs/*'"
