#!/bin/bash
# Create the backup script
# Make the backup script executable
chmod +x ~/backup_script.sh

# Check if cron job exists
existing_cron=$(crontab -l | grep "~/backup_script.sh")


# Schedule the backup script if it's not already scheduled
if [ -z "$existing_cron" ]; then
    (crontab -l 2>/dev/null; echo "10 17 * * * ~/backup_script.sh") | crontab -
    echo "Backup script scheduled to run daily at 17:10."
else
    echo "Backup script already scheduled."
fi
