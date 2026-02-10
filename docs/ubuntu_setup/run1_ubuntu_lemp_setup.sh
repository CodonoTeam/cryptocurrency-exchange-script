#!/bin/bash

# ============================================
# Codono Exchange - Ubuntu LEMP Stack Setup
# Replaces OneInStack with standard apt packages
# Supports: Ubuntu 22.04, 24.04
# ============================================

set -e

# Skip screen session if called from codono_init.sh (CODONO_NO_SCREEN=1)
if [ "$CODONO_NO_SCREEN" != "1" ]; then
    # Check if 'screen' is installed, if not then install it
    if ! command -v screen &> /dev/null; then
        echo "'screen' is not installed. Attempting to install..."
        sudo apt-get update && sudo apt-get install -y screen
        if [ $? -eq 0 ]; then
            echo "'screen' successfully installed."
        else
            echo "Failed to install 'screen'. Exiting."
            exit 1
        fi
    fi

    # Check if inside a screen session. If not, start a new screen session to run this script.
    if [ -z "$STY" ]; then
        screen -dm -S codono /bin/bash "$0"
        echo "Started setup in a screen session named codono. This process can take 5-10 mins. You can reattach with 'screen -r codono'."
        exit
    fi
fi

# Check if credentials.yml exists
if [ -f /opt/credentials.yml ]; then
    echo "credentials.yml already exists. Using existing credentials."
    # Load existing credentials
    HTACCESS_USERNAME=$(grep 'HTACCESS_USERNAME' /opt/credentials.yml | awk '{print $2}')
    HTACCESS_PASSWORD=$(grep 'HTACCESS_PASSWORD' /opt/credentials.yml | awk '{print $2}')
    REDIS_PASSWORD=$(grep 'REDIS_PASSWORD' /opt/credentials.yml | awk '{print $2}')
    MYSQL_NEW_ROOT_PASSWORD=$(grep 'MYSQL_NEW_ROOT_PASSWORD' /opt/credentials.yml | awk '{print $2}')
    DB_NAME=$(grep 'DB_NAME' /opt/credentials.yml | awk '{print $2}')
    ADMIN_KEY=$(grep 'ADMIN_KEY' /opt/credentials.yml | awk '{print $2}')
    CRON_KEY=$(grep 'CRON_KEY' /opt/credentials.yml | awk '{print $2}')
    ADMIN_USER=$(grep 'ADMIN_USER' /opt/credentials.yml | awk '{print $2}')
    ADMIN_PASS=$(grep 'ADMIN_PASS' /opt/credentials.yml | awk '{print $2}')
    TWO_FA_SECRET_KEY=$(grep 'TWO_FA_SECRET_KEY' /opt/credentials.yml | awk '{print $2}')
    domain=$(grep '^DOMAIN' /opt/credentials.yml | awk '{print $2}')
    frontend_domain=$(grep 'FRONTEND_DOMAIN' /opt/credentials.yml | awk '{print $2}')
else
    # Prompt user for domain name input
    read -p "Please input domain (example: myexchange.com): " user_domain
    user_domain=${user_domain,,} # Convert to lowercase

    # Clean the input: remove https://, http://, www, and trailing slashes
    user_domain=$(echo "$user_domain" | sed -e 's/^https:\/\///' -e 's/^http:\/\///' -e 's/^www\.//' -e 's/\/$//')

    # Derive both domains from user input
    frontend_domain="$user_domain"
    domain="api.${user_domain}"

    echo "API Domain (backend): $domain"
    echo "Frontend Domain: $frontend_domain"

    # Generate random credentials
    generate_password() {
        local length=$1
        tr -dc A-Za-z0-9 </dev/urandom | head -c ${length} ; echo ''
    }
    generate_2fa_secret_key() {
        local random_bytes=$(openssl rand 10)
        local secret_key=$(echo -n "$random_bytes" | base32 | tr -d '=')
        echo "$secret_key"
    }

    # Generating credentials with prefixes
    HTACCESS_USERNAME="HU_$(generate_password 16)"
    HTACCESS_PASSWORD="HP_$(generate_password 32)"
    REDIS_PASSWORD="$(generate_password 16)"
    MYSQL_NEW_ROOT_PASSWORD="MP_$(generate_password 40)"
    DB_NAME="DBN_$(generate_password 16)"
    ADMIN_KEY="AK_$(generate_password 42)"
    CRON_KEY="CK_$(generate_password 40)"
    ADMIN_USER="AU_$(generate_password 11)"
    ADMIN_PASS="AP_$(generate_password 40)"
    TWO_FA_SECRET_KEY=$(generate_2fa_secret_key)

    cd /opt/
    # Save credentials to YAML file
    cat <<EOF >credentials.yml
HTACCESS_USERNAME: $HTACCESS_USERNAME
HTACCESS_PASSWORD: $HTACCESS_PASSWORD
REDIS_PASSWORD: $REDIS_PASSWORD
MYSQL_NEW_ROOT_PASSWORD: $MYSQL_NEW_ROOT_PASSWORD
DB_NAME: $DB_NAME
ADMIN_KEY: $ADMIN_KEY
CRON_KEY: $CRON_KEY
ADMIN_USER: $ADMIN_USER
ADMIN_PASS: $ADMIN_PASS
TWO_FA_SECRET_KEY: $TWO_FA_SECRET_KEY
DOMAIN: $domain
FRONTEND_DOMAIN: $frontend_domain
EOF
    chmod 600 /opt/credentials.yml
    echo "Credentials have been saved to /opt/credentials.yml"
fi

# Step 1: Add Ondrej PPA for PHP 7.4
echo "Adding Ondrej PHP PPA..."
apt-get update
apt-get install -y software-properties-common apt-transport-https ca-certificates curl gnupg
add-apt-repository ppa:ondrej/php -y
apt-get update

# Step 2: Install Nginx
echo "Installing Nginx..."
apt-get install -y nginx

# Step 3: Install PHP 7.4 and extensions
echo "Installing PHP 7.4 and extensions..."
apt-get install -y \
    php7.4-fpm \
    php7.4-cli \
    php7.4-mysql \
    php7.4-redis \
    php7.4-curl \
    php7.4-xml \
    php7.4-mbstring \
    php7.4-zip \
    php7.4-gd \
    php7.4-bcmath \
    php7.4-gmp \
    php7.4-intl \
    php7.4-opcache \
    php7.4-soap \
    php7.4-readline \
    php7.4-memcached
# Note: php7.4-json is built into PHP 7.4 (not a separate package)
# Note: php7.4-fileinfo is included in php7.4-common (installed as dependency)

# Install swoole via PECL if not available as apt package
if ! apt-get install -y php7.4-swoole 2>/dev/null; then
    echo "php7.4-swoole not available via apt, installing via PECL..."
    apt-get install -y php7.4-dev php-pear
    # Pipe empty responses to avoid interactive prompts (enable openssl, http2, etc.)
    printf '\n\n\n\n\n' | pecl install swoole
    echo "extension=swoole.so" > /etc/php/7.4/mods-available/swoole.ini
    phpenmod -v 7.4 swoole
fi

# Step 4: Install MariaDB
echo "Installing MariaDB..."
apt-get install -y mariadb-server mariadb-client

# Step 5: Install Redis
echo "Installing Redis..."
apt-get install -y redis-server

# Step 6: Install Memcached
echo "Installing Memcached..."
apt-get install -y memcached

# Step 7: Install utilities
echo "Installing utilities..."
apt-get install -y apache2-utils unzip wget curl

# Step 8: Configure PHP - remove exec and stream_socket_server from disable_functions
echo "Configuring PHP..."
for ini_file in /etc/php/7.4/fpm/php.ini /etc/php/7.4/cli/php.ini; do
    if [ -f "$ini_file" ]; then
        # Remove exec from disable_functions (handle: middle of list, end of list, only item)
        sed -i '/disable_functions/s/exec,\s*//' "$ini_file"
        sed -i '/disable_functions/s/,\s*exec//' "$ini_file"
        # Remove stream_socket_server from disable_functions
        sed -i '/disable_functions/s/stream_socket_server,\s*//' "$ini_file"
        sed -i '/disable_functions/s/,\s*stream_socket_server//' "$ini_file"
        # Ensure allow_url_fopen is On (required by Codono)
        sed -i 's/^allow_url_fopen\s*=.*/allow_url_fopen = On/' "$ini_file"
    fi
done
systemctl restart php7.4-fpm

echo "GMP extension installed via apt (php7.4-gmp). No compilation needed."

# Step 9: Configure MariaDB
echo "Configuring MariaDB..."
# Ensure bind-address is set to localhost only
if [ -f /etc/mysql/mariadb.conf.d/50-server.cnf ]; then
    sed -i 's/^bind-address\s*=.*/bind-address = 127.0.0.1/' /etc/mysql/mariadb.conf.d/50-server.cnf
fi
systemctl restart mariadb

# Set root password (Ubuntu MariaDB defaults to unix_socket auth)
# Use IDENTIFIED BY which works on all MariaDB versions (PASSWORD() removed in 10.11+)
mariadb -e "ALTER USER 'root'@'localhost' IDENTIFIED VIA mysql_native_password USING PASSWORD('$MYSQL_NEW_ROOT_PASSWORD'); FLUSH PRIVILEGES;" 2>/dev/null || \
mariadb -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_NEW_ROOT_PASSWORD'; FLUSH PRIVILEGES;" 2>/dev/null || \
mariadb -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('$MYSQL_NEW_ROOT_PASSWORD'); FLUSH PRIVILEGES;" 2>/dev/null

systemctl restart mariadb

# Step 10: Setup Nginx basic auth (replaces Apache .htaccess auth)
echo "Setting up Nginx basic auth..."
htpasswd -cb /etc/nginx/.htpasswd "$HTACCESS_USERNAME" "$HTACCESS_PASSWORD"

# Step 11: Configure Redis with password
echo "Configuring Redis..."
# Handle both commented and uncommented forms with varying whitespace
sed -i "s/^#\s*requirepass\s\+.*/requirepass $REDIS_PASSWORD/" /etc/redis/redis.conf
sed -i "s/^requirepass\s\+.*/requirepass $REDIS_PASSWORD/" /etc/redis/redis.conf
# If no requirepass line exists at all, append it
if ! grep -q "^requirepass" /etc/redis/redis.conf; then
    echo "requirepass $REDIS_PASSWORD" >> /etc/redis/redis.conf
fi
systemctl restart redis-server

# Step 12: Create web root directory
echo "Creating web root directory..."
mkdir -p /data/wwwroot
chown -R www-data:www-data /data/wwwroot

# Step 13: Enable and start all services
echo "Enabling and starting services..."
systemctl enable nginx
systemctl enable php7.4-fpm
systemctl enable mariadb
systemctl enable redis-server
systemctl enable memcached

systemctl restart nginx
systemctl restart php7.4-fpm

# Print credentials
echo ""
echo "=========================================="
echo "  LEMP Stack Installation Complete!      "
echo "=========================================="
echo ""
echo "MySQL Root Password: $MYSQL_NEW_ROOT_PASSWORD"
echo "Redis Password: $REDIS_PASSWORD"
echo "Nginx Auth Username: $HTACCESS_USERNAME"
echo "Nginx Auth Password: $HTACCESS_PASSWORD"
echo "API Domain: $domain"
echo "Frontend Domain: $frontend_domain"
echo ""
echo "All credentials saved to: /opt/credentials.yml"
echo ""
