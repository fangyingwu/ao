#!/bin/bash
# Create the backup script
cat <<EOF >"~/backup_script.sh"
#!/bin/bash
TAR_FILE=$(date +%Y%m%d)"_quil_store_backup.tar.gz"

DIR_TO_TAR=$HOME"/ceremonyclient/node/.config"
mkdir ~/backup-quil
cd ~/backup-quil
echo "Creating tar file of $DIR_TO_TAR..."
sudo tar -zcvf $TAR_FILE $DIR_TO_TAR
if [ $? -eq 0 ]; then
    echo "Tar file created successfully: $TAR_FILE"
else
    echo "Error creating tar file" >&2
    exit 1
fi
echo "Script execution completed."
EOF

# Make the backup script executable
chmod +x ~/backup_script.sh

# Check if cron job exists
existing_cron=$(crontab -l | grep "~/backup_script.sh")


# Schedule the backup script if it's not already scheduled
if [ -z "$existing_cron" ]; then
    (crontab -l 2>/dev/null; echo "50 14 * * * ~/backup_script.sh") | crontab -
    echo "Backup script scheduled to run daily at 14:50."
else
    echo "Backup script already scheduled."
fi
