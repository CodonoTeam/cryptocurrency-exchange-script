#!/bin/bash

# Paths
CONFIG_FILE="/data/wwwroot/codebase/pure_config.php"
OUTPUT_FILE="/data/wwwroot/codebase/date_admin.changed"

# Read DB_NAME, DB_USER, DB_PWD, and ADMIN_KEY from pure_config.php
DB_NAME=$(grep -oP "(?<=const DB_NAME = ')[^']+" "$CONFIG_FILE")
DB_USER=$(grep -oP "(?<=const DB_USER = ')[^']+" "$CONFIG_FILE")
DB_PWD=$(grep -oP "(?<=const DB_PWD = ')[^']+" "$CONFIG_FILE")
ADMIN_KEY=$(grep -oP "(?<=const ADMIN_KEY = ')[^']+" "$CONFIG_FILE")

# Generate new admin username, password, and ADMIN_KEY
NEW_ADMIN_USERNAME="adm_$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1)"
NEW_ADMIN_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 38 | head -n 1)
NEW_ADMIN_PASSWORD_HASH=$(echo -n "$NEW_ADMIN_PASSWORD" | md5sum | awk '{print $1}')
NEW_ADMIN_KEY="ADM_$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 37 | head -n 1)"

# Update database with new admin username and password
mysql -u "$DB_USER" -p"$DB_PWD" -e "USE $DB_NAME; UPDATE codono_admin SET username='$NEW_ADMIN_USERNAME', password='$NEW_ADMIN_PASSWORD_HASH';"

# Update ADMIN_KEY in the configuration file
sed -i "s/const ADMIN_KEY = '[^']*'/const ADMIN_KEY = '$NEW_ADMIN_KEY'/" "$CONFIG_FILE"

# Log changes to date_admin.changed
echo "Admin Username: $NEW_ADMIN_USERNAME" >> "$OUTPUT_FILE"
echo "Admin Password (hashed): $NEW_ADMIN_PASSWORD_HASH" >> "$OUTPUT_FILE"
echo "Admin Password (plain): $NEW_ADMIN_PASSWORD" >> "$OUTPUT_FILE"
echo "ADMIN_KEY: $NEW_ADMIN_KEY" >> "$OUTPUT_FILE"

echo "Changes applied and saved in $OUTPUT_FILE."
