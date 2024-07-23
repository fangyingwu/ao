#!/bin/bash

wget https://github.com/EvrmoreOrg/Evrmore/releases/download/v1.0.5/evrmore-1.0.5-b0320a173-x86_64-linux-gnu.tar.gz
tar -zxvf evrmore-1.0.5-b0320a173-x86_64-linux-gnu.tar.gz
cd evrmore-1.0.5-b0320a173
sudo mv bin/* /usr/local/bin/
mkdir -p ~/.evrmore
password=password
# Create evrmore.conf file
tee <<EOF >/dev/null ~/.evrmore/evrmore.conf
server=1
rpcuser=evrmore
rpcpassword=$password
rpcallowip=172.0.0.0/8
rpcallowip=0.0.0.0/0
rpcbind=0.0.0.0
rpcport=8819
listen=1
daemon=1
assetindex=1
txindex=1
addressindex=1
timestampindex=1
spentindex=1
EOF

sudo tee <<EOF >/dev/null /etc/systemd/system/evrmored.service
[Unit]
Description=evrmored
After=network-online.target
[Service]
User=$USER
ExecStart=/usr/local/bin/evrmored -daemon -conf=$HOME/.evrmore/evrmore.conf -pid=$HOME/.evrmore/evrmored.pid
Restart=on-failure
RestartSec=3
LimitNOFILE=10000
PIDFile=$HOME/.evrmore/evrmored.pid
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable evrmored
sudo systemctl restart evrmored

#install satori
curl -fsSL https://get.docker.com | sh
sudo groupadd docker
sudo usermod -aG docker $CURRENT_USER
newgrp docker

cd ~
wget http://89.58.62.213/satori.zip

unzip ~/satori.zip
rm ~/satori.zip
cd ~/.satori
sudo DEBIAN_FRONTEND=noninteractive apt-get install python3-venv -y
bash install.sh
bash install_service.sh
