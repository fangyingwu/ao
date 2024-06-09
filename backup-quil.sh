#!/bin/bash
# Get the current date in YYYYMMDD format
#current_date=20240609

# Define the tar file name using current date and peer_id
TAR_FILE=$(date +%Y%m%d)"_quil_store_backup.tar.gz"

# Define the directory to be tarred
DIR_TO_TAR=$HOME"/ceremonyclient/node/.config"


# Create a tar.gz file of the specified directory
mkdir ~/backup-quil
cd ~/backup-quil
echo "Creating tar file of $DIR_TO_TAR..."
#tar -czf "$TAR_FILE" -C "$(dirname "$DIR_TO_TAR")" "$(basename "$DIR_TO_TAR")"
sudo tar -zcvf $TAR_FILE $DIR_TO_TAR

if [ $? -eq 0 ]; then
    echo "Tar file created successfully: $TAR_FILE"
else
    echo "Error creating tar file" >&2
    exit 1
fi
echo "Script execution completed."
