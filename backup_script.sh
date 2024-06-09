##!/bin/bash
#TAR_FILE=$(date +%Y%m%d)"_quil_store_backup.tar.gz"
#
#DIR_TO_TAR=$HOME"/ceremonyclient/node/.config"
#
#mkdir ~/backup-quil
#cd ~/backup-quil
#echo "Creating tar file of $DIR_TO_TAR..."
#sudo tar -zcvf $TAR_FILE $DIR_TO_TAR
#if [ $? -eq 0 ]; then
#    echo "Tar file created successfully: $TAR_FILE"
#else
#    echo "Error creating tar file" >&2
#    exit 1
#fi
#echo "Script execution completed."
mkdir -p  ~/backup-quil
sudo cp -r ~/ceremonyclient/node/.config  ~/backup-quil/config_$(date +%Y%m%d)

