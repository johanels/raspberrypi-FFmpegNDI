#!/usr/bin/env bash

# Do updates and upgrades
sudo apt-get -y update
sudo apt-get -y dist-upgrade
sudo apt-get -y upgrade

# Add avahi for NDI discovery
sudo apt-get install -y avahi-daemon avahi-utils
sudo bash -c 'cat << EOF > /etc/avahi/avahi-daemon.conf
[server]
use-ipv4=yes
enable-dbus=no
ratelimit-interval-usec=1000000
ratelimit-burst=1000

[wide-area]
enable-wide-area=yes

[publish]
publish-hinfo=no
publish-workstation=no

[reflector]

[rlimits]
EOF'

# Install dependencies
sudo apt-get install -y \
      autoconf \
      cmake \
      expat \
      git \
      gperf \
      libtool \
      libsdl2-dev \
      yasm \
      zlib1g-dev

# Make some space
sudo apt-get purge -y python3 python3.5

# Restart
sudo shutdown -r now

# NewTek NDI® SDK
mkdir -p /tmp/ndi
cd /tmp/ndi
wget http://new.tk/NDISDKLINUX
chmod 777 NDISDKLINUX
./NDISDKLINUX
sudo mv "NDI SDK for Linux"/include/* /usr/local/include/
case $(cat /proc/device-tree/model) in
  "Raspberry Pi 1"*)
    echo "NewTek NDI® SDK Raspberry Pi 1"
    sudo mv "NDI SDK for Linux"/lib/armv6-rpi-linux-gnueabi/* /usr/local/lib/
    ;;
  "Raspberry Pi 2"*)
    echo "NewTek NDI® SDK Raspberry Pi 2"
    sudo mv "NDI SDK for Linux"/lib/armv7-rpi2-linux-gnueabihf/* /usr/local/lib/
    ;;
  "Raspberry Pi 3"*)
    echo "NewTek NDI® SDK Raspberry Pi 3"
    sudo mv "NDI SDK for Linux"/lib/armv8-rpi3-linux-gnueabihf/* /usr/local/lib/
    ;;
  *)
    echo "I have no clue what we are running on..."
    ;;
esac
cd /
rm -rf /tmp/ndi

# ffmpeg https://ffmpeg.org/
```bash
mkdir -p /tmp/ffmpeg
cd /tmp/ffmpeg
curl -sLO https://ffmpeg.org/releases/ffmpeg-4.1.tar.bz2
tar -jx --strip-components=1 -f ./ffmpeg-4.1.tar.bz2
rm ./ffmpeg-4.1.tar.bz2

./configure \
    --disable-coreimage \
    --disable-doc \
    --disable-debug \
    --disable-ffprobe \
    --disable-htmlpages \
    --disable-manpages \
    --disable-podpages \
    --disable-securetransport \
    --disable-txtpages \
    --enable-gpl \
    --enable-libndi_newtek \
    --enable-nonfree \
    --extra-cflags="-I/usr/local/include" \
    --extra-ldflags="-L/usr/local/lib" \
    --prefix="/usr/local"
make -j4
make install
make distclean
