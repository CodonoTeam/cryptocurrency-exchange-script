#!/bin/bash

# Immediately exit if any command has a non-zero exit status
set -e

# Verify /opt/credentials.yml exists
if [ ! -f "/opt/credentials.yml" ]; then
    echo "/opt/credentials.yml does not exist."
    exit 1
fi

# Extract values from /opt/credentials.yml
DOMAIN=$(grep 'DOMAIN:' /opt/credentials.yml | cut -d ' ' -f 2)
REDIS_PASSWORD=$(grep 'REDIS_PASSWORD:' /opt/credentials.yml | cut -d ' ' -f 2)
MYSQL_NEW_ROOT_PASSWORD=$(grep 'MYSQL_NEW_ROOT_PASSWORD:' /opt/credentials.yml | cut -d ' ' -f 2)
DB_NAME=$(grep 'DB_NAME:' /opt/credentials.yml | cut -d ' ' -f 2)
ADMIN_KEY=$(grep 'ADMIN_KEY:' /opt/credentials.yml | cut -d ' ' -f 2)
CRON_KEY=$(grep 'CRON_KEY:' /opt/credentials.yml | cut -d ' ' -f 2)
# Extract the first part of the domain and capitalize it for SHORT_NAME
SITE_NAME=$(echo "${DOMAIN%%.*}" | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}')


# Verify required directories exist before moving contents
if [[ -d "/data/wwwroot/${DOMAIN}" && -d "/data/wwwroot/codono_unpack/codebase" && -d "/data/wwwroot/codono_unpack/webserver" ]]; then
    echo "Moving files..."
    mv /data/wwwroot/codono_unpack/codebase /data/wwwroot/ || { echo "Failed to move codebase directory."; exit 1; }
    mv /data/wwwroot/codono_unpack/webserver/* /data/wwwroot/${DOMAIN}/ || { echo "Failed to move webserver files."; exit 1; }
    echo "Files have been moved successfully."
else
    echo "One or more required directories do not exist."
    exit 1
fi


# Check if /data/wwwroot/codebase/Runtime exists, if not then create
if [ ! -d "/data/wwwroot/codebase/Runtime" ]; then
    echo "Creating /data/wwwroot/codebase/Runtime directory..."
    mkdir -p /data/wwwroot/codebase/Runtime
fi

# Change ownership of the Runtime directory and Upload folder
chown -R www:www /data/wwwroot/codebase/Runtime
chown -R www:www /data/wwwroot/${DOMAIN}/Upload

# Define the path to your PHP configuration file
PHP_CONFIG_FILE="/data/wwwroot/codebase/pure_config.php"

# Extract values and update the pure_config.php file
echo "Updating configuration file 'pure_config.php'..."

sed -i "s|const SITE_URL = 'http://exchange.local/';|const SITE_URL = 'https://${DOMAIN}/';|g" "$PHP_CONFIG_FILE"
sed -i "s|const DB_NAME = 'codonoexchange';|const DB_NAME = '$DB_NAME';|g" "$PHP_CONFIG_FILE"
sed -i "s|const DB_PWD = '';|const DB_PWD = '$MYSQL_NEW_ROOT_PASSWORD';|g" "$PHP_CONFIG_FILE"
sed -i "s|const ADMIN_KEY = 'securekey';|const ADMIN_KEY = '$ADMIN_KEY';|g" "$PHP_CONFIG_FILE"
sed -i "s|const CRON_KEY = 'cronkey';|const CRON_KEY = '$CRON_KEY';|g" "$PHP_CONFIG_FILE"
sed -i "s|const PHP_PATH = 'php';|const PHP_PATH = '/usr/local/php/bin/php';|g" "$PHP_CONFIG_FILE"
sed -i "s|const DB_PORT = '3309';|const DB_PORT = '3306';|g" "$PHP_CONFIG_FILE"
sed -i "s|const M_DEBUG = 1;|const M_DEBUG = 0;|g" "$PHP_CONFIG_FILE"
sed -i "s|const REDIS_PASSWORD = 'nf4gb45g8b5489gb54g89b';|const REDIS_PASSWORD = '$REDIS_PASSWORD';|g" "$PHP_CONFIG_FILE"
sed -i "s|const SHORT_NAME = 'Codono';|const SHORT_NAME = '$SITE_NAME';|g" "$PHP_CONFIG_FILE"

# put .htaccess in its place 
mv /data/wwwroot/${DOMAIN}/example.htaccess /data/wwwroot/${DOMAIN}/.htaccess

echo "Configuration file 'pure_config.php' has been updated successfully. You can now run run4_db_create_and_import.sh for db creation and sql import"
