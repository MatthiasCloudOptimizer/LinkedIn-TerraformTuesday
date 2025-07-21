#!/bin/bash
set -euo pipefail

DISK_SIZE_GB=30
MOUNT_PT="/srv/minecraft"
MC_USER="mc"
SERVER_VERSION="1.21.0.03"
DOWNLOAD_URL="https://minecraft.azureedge.net/bin-linux/bedrock-server-${SERVER_VERSION}.zip"

# Disk finden, partitionieren, formatieren, mounten
DEV=$(lsblk -nd -o NAME,SIZE | grep -E " ${DISK_SIZE_GB}G$" | awk '{print $1}' | head -n1)
DEV="/dev/$DEV"
sudo parted $DEV --script mklabel gpt mkpart primary ext4 0% 100%
sudo mkfs.ext4 -L mcdata ${DEV}1
[[ -d $MOUNT_PT ]] || sudo mkdir -p $MOUNT_PT
UUID=$(sudo blkid -s UUID -o value ${DEV}1)
grep -q "$UUID" /etc/fstab || echo "UUID=$UUID $MOUNT_PT ext4 defaults,nofail,discard 0 2" | sudo tee -a /etc/fstab
sudo mount -a

# User, Pakete, libssl1.1
sudo adduser --system --group --home $MOUNT_PT $MC_USER || true
sudo apt update
sudo apt install -y unzip screen libcurl4 libsodium23
if ! dpkg -s libssl1.1 &>/dev/null; then
    wget -qO /tmp/libssl.deb https://launchpad.net/ubuntu/+archive/primary/+files/libssl1.1_1.1.1f-1ubuntu2_amd64.deb
    sudo dpkg -i /tmp/libssl.deb
    rm /tmp/libssl.deb
fi

# Bedrock Server holen und konfigurieren
sudo -u $MC_USER bash -c "
    cd $MOUNT_PT
    wget -qO bedrock.zip $DOWNLOAD_URL
    unzip -o bedrock.zip && rm bedrock.zip
    chmod +x bedrock_server
    grep -q \"view-distance\" server.properties 2>/dev/null || cat > server.properties <<EOF
enable-lan-visibility=false
view-distance=10
tick-distance=6
max-threads=4
compression-threshold=256
compression-algorithm=snappy
client-side-chunk-generation-enabled=true
server-build-radius-ratio=Disabled
player-idle-timeout=30
EOF
"

# systemd-Service
sudo tee /etc/systemd/system/bedrock.service > /dev/null <<'UNIT'
[Unit]
Description=Minecraft Bedrock Server
After=network.target

[Service]
User=mc
WorkingDirectory=/srv/minecraft
ExecStart=/usr/bin/screen -DmS bedrock /srv/minecraft/bedrock_server
ExecStop=/usr/bin/screen -S bedrock -X quit
Restart=on-failure
Nice=-5
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
UNIT

sudo systemctl daemon-reload
sudo systemctl enable --now bedrock