#!/bin/bash

# Define log file
LOG_FILE="/var/log/codono-install.log"

# Function to log messages with redaction for sensitive information
log() {
    case "$1" in
        *PASSWORD*|*SECRET_KEY*)
            echo "*** Redacted Sensitive Information ***" | tee -a "$LOG_FILE"
            ;;
        *)
            echo "$1" | tee -a "$LOG_FILE"
            ;;
    esac
}


# Check if 'screen' is installed, if not then install it
if ! command -v screen &> /dev/null; then
    echo "'screen' is not installed. Attempting to install..."
    # Use apt-get if you are on Debian/Ubuntu. Adjust as needed for other distros (yum, zypper, pacman, etc.)
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
    echo "Started setup in a screen session named codono , This process can take upto 10-20 mins. You can reattach to it with 'screen -r codono'."
    exit
fi


# Function to load credentials from credentials.yml using yq if available
load_credentials() {
    if command -v yq &> /dev/null; then
        HTACCESS_USERNAME=$(yq e '.HTACCESS_USERNAME' /opt/credentials.yml)
        HTACCESS_PASSWORD=$(yq e '.HTACCESS_PASSWORD' /opt/credentials.yml)
        REDIS_PASSWORD=$(yq e '.REDIS_PASSWORD' /opt/credentials.yml)
        MYSQL_NEW_ROOT_PASSWORD=$(yq e '.MYSQL_NEW_ROOT_PASSWORD' /opt/credentials.yml)
        DB_NAME=$(yq e '.DB_NAME' /opt/credentials.yml)
        ADMIN_KEY=$(yq e '.ADMIN_KEY' /opt/credentials.yml)
        CRON_KEY=$(yq e '.CRON_KEY' /opt/credentials.yml)
        ADMIN_USER=$(yq e '.ADMIN_USER' /opt/credentials.yml)
        ADMIN_PASS=$(yq e '.ADMIN_PASS' /opt/credentials.yml)
        TWO_FA_SECRET_KEY=$(yq e '.TWO_FA_SECRET_KEY' /opt/credentials.yml)
        REPLICATION_USER_PASSWORD=$(yq e '.REPLICATION_USER_PASSWORD' /opt/credentials.yml)
        domain=$(yq e '.DOMAIN' /opt/credentials.yml)
        master_ip=$(yq e '.MASTER_IP' /opt/credentials.yml)
        slave_ip=$(yq e '.SLAVE_IP' /opt/credentials.yml)
        MEMCACHED_SERVERS=$(yq e '.MEMCACHED_SERVERS' /opt/credentials.yml)
    else
        log "Warning: 'yq' not installed. Falling back to awk for parsing."
        HTACCESS_USERNAME=$(awk -F': ' '/HTACCESS_USERNAME/ {print $2}' /opt/credentials.yml)
        HTACCESS_PASSWORD=$(awk -F': ' '/HTACCESS_PASSWORD/ {print $2}' /opt/credentials.yml)
        REDIS_PASSWORD=$(awk -F': ' '/REDIS_PASSWORD/ {print $2}' /opt/credentials.yml)
        MYSQL_NEW_ROOT_PASSWORD=$(awk -F': ' '/MYSQL_NEW_ROOT_PASSWORD/ {print $2}' /opt/credentials.yml)
        DB_NAME=$(awk -F': ' '/DB_NAME/ {print $2}' /opt/credentials.yml)
        ADMIN_KEY=$(awk -F': ' '/ADMIN_KEY/ {print $2}' /opt/credentials.yml)
        CRON_KEY=$(awk -F': ' '/CRON_KEY/ {print $2}' /opt/credentials.yml)
        ADMIN_USER=$(awk -F': ' '/ADMIN_USER/ {print $2}' /opt/credentials.yml)
        ADMIN_PASS=$(awk -F': ' '/ADMIN_PASS/ {print $2}' /opt/credentials.yml)
        TWO_FA_SECRET_KEY=$(awk -F': ' '/TWO_FA_SECRET_KEY/ {print $2}' /opt/credentials.yml)
        REPLICATION_USER_PASSWORD=$(awk -F': ' '/REPLICATION_USER_PASSWORD/ {print $2}' /opt/credentials.yml)
        domain=$(awk -F': ' '/DOMAIN/ {print $2}' /opt/credentials.yml)
        master_ip=$(awk -F': ' '/MASTER_IP/ {print $2}' /opt/credentials.yml)
        slave_ip=$(awk -F': ' '/SLAVE_IP/ {print $2}' /opt/credentials.yml)
        MEMCACHED_SERVERS=$(awk -F': ' '/MEMCACHED_SERVERS/ {print $2}' /opt/credentials.yml)
    fi
}

# Function to validate domain format
validate_domain() {
    local domain_regex="^([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$"
    [[ $1 =~ $domain_regex ]]
}

# Check if credentials.yml exists
if [ -f /opt/credentials.yml ]; then
    if [ ! -w /opt/credentials.yml ]; then
        log "Error: /opt/credentials.yml is not writable. Please check permissions."
        exit 1
    fi
    log "credentials.yml already exists. Using existing credentials."
    load_credentials
    is_single="n"
else
    # Check if /opt is writable
    if [ ! -w /opt/ ]; then
        log "Error: /opt/ directory is not writable. Please check permissions."
        exit 1
    fi

    # Prompt for domain name with validation
    while [[ -z "$domain" || ! $(validate_domain "$domain") ]]; do
        read -p "Please input domain (example: example.com): " domain
        domain=${domain,,} # Convert to lowercase
        domain=$(echo "$domain" | sed -e 's/^https:\/\///' -e 's/^www\.//' -e 's/\/$//')
    done

    # Ask if single or multi-server setup
    while [[ ! "$is_single" =~ ^[YyNn]$ ]]; do
        read -p "Is this a single server setup? (y/n): " is_single
        is_single=${is_single,,} # Convert to lowercase
    done

    if [ "$is_single" != "y" ]; then
        while [[ -z "$master_ip" ]]; do
            read -p "Enter MariaDB master server IP: " master_ip
        done
        while [[ -z "$slave_ip" ]]; do
            read -p "Enter MariaDB slave server IP: " slave_ip
        done
        
        # Automatically configure memcached servers using master and slave IPs
        MEMCACHED_SERVERS="${master_ip}:11211,${slave_ip}:11211"
    fi

    # Step 0: Create random credentials
    generate_password() {
        openssl rand -hex 16
    }
    generate_2fa_secret_key() {
        local random_bytes=$(openssl rand 10)
        local secret_key=$(echo -n "$random_bytes" | base32 | tr -d '=')
        echo "$secret_key"
    }

    # Generating credentials
    HTACCESS_USERNAME=$(generate_password)
    HTACCESS_PASSWORD=$(generate_password)
    REDIS_PASSWORD=$(generate_password)
    MYSQL_NEW_ROOT_PASSWORD=$(generate_password)
    REPLICATION_USER_PASSWORD=$(generate_password)
    ADMIN_USER=$(generate_password)
    ADMIN_PASS=$(generate_password)
    DB_NAME=$(generate_password)
    ADMIN_KEY=$(generate_password)
    CRON_KEY=$(generate_password)
    TWO_FA_SECRET_KEY=$(generate_2fa_secret_key)

    # Save credentials to a YAML file in /opt
    cat <<EOF >/opt/credentials.yml
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
REPLICATION_USER_PASSWORD: $REPLICATION_USER_PASSWORD
DOMAIN: $domain
EOF
    if [ "$is_single" != "y" ]; then
        echo "MASTER_IP: $master_ip" >> /opt/credentials.yml
        echo "SLAVE_IP: $slave_ip" >> /opt/credentials.yml
        echo "MEMCACHED_SERVERS: $MEMCACHED_SERVERS" >> /opt/credentials.yml
    fi
    chmod 600 /opt/credentials.yml
    log "Credentials have been saved to /opt/credentials.yml."
fi

# Step 1: Install OneInStack
cd /opt/ || { log "Failed to cd to /opt"; exit 1; }
if ! (wget -c http://mirrors.oneinstack.com/oneinstack-full.tar.gz -O oneinstack-full.tar.gz); then
    log "Primary mirror failed. Trying backup mirror..."
    if ! (wget -c http://mirrors.linuxeye.com/oneinstack-full.tar.gz -O oneinstack-full.tar.gz); then
        log "Both mirrors failed. Exiting."
        exit 1
    fi
fi

# Check if the file is a valid tar archive
if ! tar tzf oneinstack-full.tar.gz &>/dev/null; then
    log "Downloaded file is corrupt. Exiting."
    rm -f oneinstack-full.tar.gz
    exit 1
fi

tar xzf oneinstack-full.tar.gz || { log "Extraction failed. Exiting."; exit 1; }
export MYSQL_NEW_ROOT_PASSWORD
if ! (./oneinstack/install.sh --nginx_option 1 --apache --apache_mpm_option 1 --apache_mode_option 1 \
    --php_option 9 --phpcache_option 1 --php_extensions fileinfo,redis,swoole,memcached \
    --phpmyadmin --db_option 5 --dbinstallmethod 1 --dbrootpwd "$MYSQL_NEW_ROOT_PASSWORD" --redis --memcached); then
    log "OneInStack installation failed."
    exit 1
fi

# Step 2: Modify php.ini
PHP_INI="/usr/local/php/etc/php.ini"
if [ -f "$PHP_INI" ]; then
    sed -i 's/disable_functions\s*=\s*/disable_functions = /' "$PHP_INI"
    log "Updated php.ini. Restarting PHP service..."
    systemctl restart php-fpm
else
    log "php.ini file not found. Skipping modifications."
fi

# Step 3: Install GMP extension
cd /opt/oneinstack/src || { log "Failed to cd to /opt/oneinstack/src"; exit 1; }
tar xzf php-7.4.33.tar.gz || { log "Failed to extract php-7.4.33.tar.gz"; exit 1; }
cd php-7.4.33/ext/gmp || { log "Failed to cd to php-7.4.33/ext/gmp"; exit 1; }
if ! (apt install libgmp-dev -y && /usr/local/php/bin/phpize && ./configure --with-php-config=/usr/local/php/bin/php-config && make && make install); then
    log "GMP extension installation failed."
    exit 1
fi
echo 'extension=gmp.so' > /usr/local/php/etc/php.d/gmp.ini
if ! (systemctl restart php-fpm); then
    log "Failed to restart PHP-FPM after GMP installation."
    exit 1
fi
log "GMP extension installation is complete."

# Step 4: Configure MySQL Master-Slave Replication
if [ "$is_single" != "y" ]; then
    current_ip=$(hostname -I | awk '{print $1}')
    
    # Master Server Configuration
    if [ "$current_ip" == "$master_ip" ]; then
        # Configure master
        if ! (sed -i '/\[mariadb\]/a log_bin\nserver_id=1\nbinlog_format=mixed\nlog-basename=master1' /etc/my.cnf && systemctl restart mariadb); then
            log "Failed to configure MariaDB master settings."
            exit 1
        fi
        
        # Create replication user with SSL requirement
        if ! (mysql -e "CREATE USER 'replication_user'@'$slave_ip' IDENTIFIED BY '$REPLICATION_USER_PASSWORD';" && mysql -e "GRANT REPLICATION SLAVE ON *.* TO 'replication_user'@'$slave_ip';" && mysql -e "FLUSH PRIVILEGES;"); then
            log "Failed to create replication user."
            exit 1
        fi
        
        # Get master status
        MASTER_LOG_FILE=$(mysql -e "SHOW MASTER STATUS;" | awk '{print $1}')
        MASTER_LOG_POS=$(mysql -e "SHOW MASTER STATUS;" | awk '{print $2}')
        
        # Save master status to credentials.yml
        sed -i "/MYSQL_NEW_ROOT_PASSWORD/a MASTER_LOG_FILE: $MASTER_LOG_FILE" /opt/credentials.yml
        sed -i "/MASTER_LOG_FILE/a MASTER_LOG_POS: $MASTER_LOG_POS" /opt/credentials.yml
        
        # Configure SSL for replication
        if ! (mysql -e "CREATE SSL CERTIFICATE IF NOT EXISTS 'replication_ssl' IDENTIFIED BY '$REPLICATION_USER_PASSWORD';" && mysql -e "GRANT REPLICATION SLAVE ON *.* TO 'replication_user'@'$slave_ip' REQUIRE SSL;"); then
            log "Failed to configure SSL for replication."
            exit 1
        fi
    fi
    
    # Slave Server Configuration
    if [ "$current_ip" == "$slave_ip" ]; then
        # Configure slave
        if ! (sed -i '/\[mariadb\]/a server_id=2' /etc/my.cnf && systemctl restart mariadb); then
            log "Failed to configure MariaDB slave settings."
            exit 1
        fi
        
        # Configure replication with SSL
        if ! (mysql -e "CHANGE MASTER TO MASTER_HOST='$master_ip', MASTER_USER='replication_user', MASTER_PASSWORD='$REPLICATION_USER_PASSWORD', MASTER_LOG_FILE='$MASTER_LOG_FILE', MASTER_LOG_POS=$MASTER_LOG_POS, MASTER_SSL=1;" && mysql -e "START SLAVE;"); then
            log "Failed to configure replication on slave."
            exit 1
        fi
        
        # Verify replication status
        mysql -e "SHOW SLAVE STATUS\G" | grep -e "Slave_IO_Running" -e "Slave_SQL_Running" | tee -a "$LOG_FILE"
    fi
fi

# Step 5: Setup .htaccess authentication
HTPASSWD_DIR="/usr/local/apache"
HTPASSWD_FILE="$HTPASSWD_DIR/.htpasswd"
PROTECTED_DIR="/data/wwwroot/default"

if [ ! -d $HTPASSWD_DIR ]; then
    mkdir -p $HTPASSWD_DIR
fi

if ! (/usr/local/apache/bin/htpasswd -cb $HTPASSWD_FILE $HTACCESS_USERNAME $HTACCESS_PASSWORD && echo "AuthType Basic
AuthName \"Restricted Access\"
AuthUserFile $HTPASSWD_FILE
Require valid-user" > $PROTECTED_DIR/.htaccess && systemctl restart httpd); then
    log "Failed to configure .htaccess authentication."
    exit 1
fi

# Step 6: Configure Redis for memory caching across servers
# Configure Redis to listen on all interfaces
if ! (sed -i 's/bind 127.0.0.1/bind 0.0.0.0/' /usr/local/redis/etc/redis.conf && sed -i "s/^# requirepass foobared/requirepass $REDIS_PASSWORD/" /usr/local/redis/etc/redis.conf && systemctl restart redis-server); then
    log "Failed to configure Redis."
    exit 1
fi

# Step 7: Configure Memcached for session storage
if ! command -v memcached &> /dev/null; then
    if ! (sudo apt-get install -y memcached); then
        log "Failed to install memcached."
        exit 1
    fi
fi

if ! (sed -i 's/-l 127.0.0.1/-l 0.0.0.0/' /etc/memcached.conf && systemctl restart memcached); then
    log "Failed to configure Memcached."
    exit 1
fi

# Configure PHP to use Memcached for sessions
cat <<EOF >/usr/local/php/etc/php.d/memcached-session.ini
session.save_handler = memcached
session.save_path = "$MEMCACHED_SERVERS"
EOF

# Configure PHP to use Redis for caching
cat <<EOF >/usr/local/php/etc/php.d/redis-caching.ini
extension=redis.so
redis.cache.save_path = "tcp://$master_ip:6379?auth=$REDIS_PASSWORD,tcp://$slave_ip:6379?auth=$REDIS_PASSWORD"
EOF

if ! (systemctl restart php-fpm); then
    log "Failed to restart PHP-FPM after session configuration."
    exit 1
fi

# Print credentials
log "MySQL Root Password: $MYSQL_NEW_ROOT_PASSWORD"
log "Redis Password: $REDIS_PASSWORD"
log ".htaccess Username: $HTACCESS_USERNAME"
log ".htaccess Password: $HTACCESS_PASSWORD"
if [ "$is_single" != "y" ]; then
    log "MariaDB Master IP: $master_ip"
    log "MariaDB Slave IP: $slave_ip"
    log "Replication User Password: $REPLICATION_USER_PASSWORD"
    log "Master Log File: $MASTER_LOG_FILE"
    log "Master Log Position: $MASTER_LOG_POS"
    log "Memcached Servers: $MEMCACHED_SERVERS"
fi
