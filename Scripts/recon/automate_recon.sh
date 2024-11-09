#!/bin/bash

# Ensure the script is being run with root privileges for system directories like /etc/httpd and /var/www
if [ "$(id -u)" -ne "0" ]; then
    echo "This script must be run as root"
    exit 1
fi

# Set variables (adjust these to your needs)
GITHUB_REPO="https://github.com/ptcc-ccdc/onerun.git"
BRANCH_PREFIX="github"
NEW_BRANCH_NAME="recon"  # Branch name for your new changes
COMMIT_MESSAGE="Added MySQL dumps and Apache backup data"  # Commit message
BACKUP_DIR="backup"  # Name of the directory to store backups

# MySQL configuration (you should have already set the root password via mysql_secure_installation)
MYSQL_USER="root"
MYSQL_PASSWORD="your_new_root_password"  # Use the password you set earlier

# Directories to back up
WWW_DIR="/var/www"
HTTPD_CONF_DIR="/etc/httpd"

# Ensure the backup directory exists
mkdir -p $BACKUP_DIR

# Step 1: Clone the repository (if not already cloned)
if [ ! -d "onerun" ]; then
    echo "Cloning the repository..."
    git clone $GITHUB_REPO
else
    echo "Repository already cloned. Pulling the latest changes..."
    cd onerun
    git pull origin main
    cd ..
fi

# Step 2: Create MySQL Dumps (including versions)
echo "Creating MySQL dumps and collecting database versions..."

# Function to dump MySQL databases
function mysql_dump() {
    # Get the list of all databases
    DB_LIST=$(mysql -u $MYSQL_USER -p$MYSQL_PASSWORD -e 'SHOW DATABASES;' | grep -v Database)

    for DB in $DB_LIST; do
        echo "Dumping database: $DB"
        mysqldump -u $MYSQL_USER -p$MYSQL_PASSWORD $DB > "$BACKUP_DIR/${DB}_dump_$(date +%Y%m%d).sql"
    done

    # Get MySQL version
    MYSQL_VERSION=$(mysql -u $MYSQL_USER -p$MYSQL_PASSWORD -e 'SELECT VERSION();' | grep -v VERSION)
    echo "MySQL version: $MYSQL_VERSION" > "$BACKUP_DIR/mysql_version_$(date +%Y%m%d).txt"
}

mysql_dump

# Step 3: Back up Apache data (conf and logs)
echo "Backing up Apache data..."

# Copy Apache configurations and logs to backup folder
cp -r $WWW_DIR $BACKUP_DIR/
cp -r $HTTPD_CONF_DIR $BACKUP_DIR/

# Step 4: Compress the backup folder into a .tar.gz archive
echo "Compressing the backup folder into a .tar.gz archive..."
tar -czf "$BACKUP_DIR_$(date +%Y%m%d).tar.gz" -C "$BACKUP_DIR" .

# Step 5: Create a new Git branch for backup data
echo "Creating new Git branch '$BRANCH_PREFIX/$NEW_BRANCH_NAME'..."

cd onerun
git checkout -b "$BRANCH_PREFIX/$NEW_BRANCH_NAME"

# Step 6: Add, commit, and push the backup data to GitHub
echo "Adding and committing backup files to Git..."

# Add the compressed archive to Git
git add "$BACKUP_DIR_$(date +%Y%m%d).tar.gz"
git commit -m "$COMMIT_MESSAGE"

# Push the new branch to GitHub
git push origin "$BRANCH_PREFIX/$NEW_BRANCH_NAME"

# Step 7: Confirmation
echo "Backup and push to GitHub completed on branch '$BRANCH_PREFIX/$NEW_BRANCH_NAME'."
