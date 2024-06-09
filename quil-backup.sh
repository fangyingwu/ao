#!/bin/bash
# Create the backup script
sudo cat <<EOF >"$USER_HOME/backup_script.sh"
#!/bin/bash
# Get the current date in YYYYMMDD format
current_date=$(date +%Y%m%d)

# Define the tar file name using current date and peer_id
TAR_FILE="$USER_HOME/${current_date}_quil_store_backup.tar.gz"

# Define the directory to be tarred
DIR_TO_TAR="$USER_HOME/ceremonyclient/node/.config"

# Create a tar.gz file of the specified directory
echo "Creating tar file of \$DIR_TO_TAR..."
sudo tar -czf "\$TAR_FILE" -C "\$(dirname "\$DIR_TO_TAR")" "\$(basename "\$DIR_TO_TAR")"

if [ \$? -eq 0 ]; then
    echo "Tar file created successfully: \$TAR_FILE"
else
    echo "Error creating tar file" >&2
    exit 1
fi
echo "Script execution completed."
EOF

# Make the backup script executable
sudo chmod +x $USER_HOME/backup_script.sh

# Check if cron job exists
existing_cron=$(crontab -l | grep "$USER_HOME/backup_script.sh")

sudo chmod +x $USER_HOME/backup_script.sh
$USER_HOME/backup_script.sh

# Schedule the backup script if it's not already scheduled
if [ -z "$existing_cron" ]; then
    (crontab -l 2>/dev/null; echo "0 13 * * * $USER_HOME/backup_script.sh") | crontab -
    echo "Backup script scheduled to run daily at 13:00."
else
    echo "Backup script already scheduled."
fi

