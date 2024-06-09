#!/bin/bash
sudo mkdir -p ~/backup-quil

echo "15 13 * * * sudo cp -r ~/ceremonyclient/node/.config  ~/backup-quil/config_$(date +%Y%m%d)" | crontab -
