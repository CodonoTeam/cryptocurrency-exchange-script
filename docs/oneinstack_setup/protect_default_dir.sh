#!/bin/bash

# Protect /data/wwwroot/default directory with username password for codono setup

# Variables
HTPASSWD_DIR="/usr/local/apache"
HTPASSWD_FILE="$HTPASSWD_DIR/.htpasswd"
PROTECTED_DIR="/data/wwwroot/default"
USERNAME=""

# Check if running as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Create a directory for .htpasswd if it doesn't exist
if [ ! -d $HTPASSWD_DIR ]; then
    sudo mkdir -p $HTPASSWD_DIR
fi

# Create .htpasswd file
read -p "Enter the username for authentication: " USERNAME
sudo /usr/local/apache/bin/htpasswd -c $HTPASSWD_FILE $USERNAME

# Check if .htpasswd file creation was successful
if [ $? -ne 0 ]; then
    echo "Failed to create .htpasswd file"
    exit 1
fi

# Create or modify .htaccess file
echo "AuthType Basic
AuthName \"Restricted Access\"
AuthUserFile $HTPASSWD_FILE
Require valid-user" | sudo tee $PROTECTED_DIR/.htaccess

# Restart Apache to apply changes
sudo service httpd restart

echo "Basic HTTP authentication set up for $PROTECTED_DIR"
