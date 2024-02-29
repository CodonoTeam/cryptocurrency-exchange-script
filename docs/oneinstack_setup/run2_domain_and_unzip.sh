#!/bin/bash

# Immediately exit if any command has a non-zero exit status
set -e

# Prompt user for domain name input
read -p "Please input domain(example: example.com): " domain
domain=${domain,,} # Convert domain to lowercase to avoid issues

# Clean the input: remove https://, www, and trailing slashes
domain=$(echo "$domain" | sed -e 's/^https:\/\///' -e 's/^www\.//' -e 's/\/$//')

# Verify /opt/credentials.yml exists
if [ ! -f "/opt/credentials.yml" ]; then
    echo "/opt/credentials.yml does not exist."
    exit 1
fi

# Verify /data/wwwroot/codono_unpack.zip exists
if [ ! -f "/data/wwwroot/codono_unpack.zip" ]; then
    echo "/data/wwwroot/codono_unpack.zip does not exist."
    exit 1
fi

# Check if unzip is available, if not then install
if ! command -v unzip &> /dev/null; then
    echo "unzip is not installed. Installing..."
    sudo apt-get update && sudo apt-get install unzip -y
fi

# Unzip codono_unpack.zip
echo "Unzipping /data/wwwroot/codono_unpack.zip..."
unzip /data/wwwroot/codono_unpack.zip -d /data/wwwroot/ || { echo "Failed to unzip file."; exit 1; }

# Add the domain to /opt/oneinstack/vhost.sh script
echo "Adding domain to vhost.sh..."
/opt/oneinstack/vhost.sh --add <<EOF
1
$domain

n
n
y
y
EOF

# Check if the previous command was successful
if [ $? -ne 0 ]; then
    echo "Failed to add domain to vhosts.sh."
    exit 1
fi

echo "The virtual host for $domain has been configured."


# Verify required directories exist before moving contents
if [[ -d "/data/wwwroot/${domain}" && -d "/data/wwwroot/codono_unpack/codebase" && -d "/data/wwwroot/codono_unpack/webserver" ]]; then
    echo "Moving files..."
    mv /data/wwwroot/codono_unpack/codebase /data/wwwroot/ || { echo "Failed to move codebase directory."; exit 1; }
    mv /data/wwwroot/codono_unpack/webserver/* /data/wwwroot/${domain}/ || { echo "Failed to move webserver files."; exit 1; }
    echo "Files have been moved successfully."
else
    echo "One or more required directories do not exist."
    exit 1
fi

# Define the path to your PHP configuration file
PHP_CONFIG_FILE="/data/wwwroot/${domain}/pure_config.php"

# Extract values and update the pure_config.php file
echo "Updating configuration file 'pure_config.php'..."
REDIS_PASSWORD=$(grep 'REDIS_PASSWORD:' /opt/credentials.yml | cut -d ' ' -f 2)
MYSQL_NEW_ROOT_PASSWORD=$(grep 'MYSQL_NEW_ROOT_PASSWORD:' /opt/credentials.yml | cut -d ' ' -f 2)
DB_NAME=$(grep 'DB_NAME:' /opt/credentials.yml | cut -d ' ' -f 2)
ADMIN_KEY=$(grep 'ADMIN_KEY:' /opt/credentials.yml | cut -d ' ' -f 2)
CRON_KEY=$(grep 'CRON_KEY:' /opt/credentials.yml | cut -d ' ' -f 2)

sed -i "s|const SITE_URL = 'http://exchange.local/';|const SITE_URL = 'https://${domain}/';|g" "$PHP_CONFIG_FILE"
sed -i "s|const DB_NAME = 'codonoexchange';|const DB_NAME = '$DB_NAME';|g" "$PHP_CONFIG_FILE"
sed -i "s|const DB_PWD = '';|const DB_PWD = '$MYSQL_NEW_ROOT_PASSWORD';|g" "$PHP_CONFIG_FILE"
sed -i "s|const ADMIN_KEY = 'securekey';|const ADMIN_KEY = '$ADMIN_KEY';|g" "$PHP_CONFIG_FILE"
sed -i "s|const CRON_KEY = 'cronkey';|const CRON_KEY = '$CRON_KEY';|g" "$PHP_CONFIG_FILE"
sed -i "s|const PHP_PATH = 'php';|const PHP_PATH = '/usr/local/php/bin/php';|g" "$PHP_CONFIG_FILE"
sed -i "s|const DB_PORT = '3309';|const DB_PORT = '3306';|g" "$PHP_CONFIG_FILE"
sed -i "s|const M_DEBUG = 1;|const M_DEBUG = 0;|g" "$PHP_CONFIG_FILE"
sed -i "s|const REDIS_PASSWORD = 'nf4gb45g8b5489gb54g89b';|const REDIS_PASSWORD = '$REDIS_PASSWORD';|g" "$PHP_CONFIG_FILE"

echo "Configuration file 'pure_config.php' has been updated successfully. Please visit https://${domain}/install_check.php and https://${domain}/"
