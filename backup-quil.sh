#!/bin/bash
sudo mkdir -p ~/backup-quil

echo "0 0 * * * sudo cp -r ~/ceremonyclient/node/.config  ~/backup-quil/config_$(date +%Y%m%d)" | crontab -
