#!/bin/bash

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
    echo "Started setup in a screen session named codono. This process can take upto 10-20 mins. You can reattach to it with 'screen -r codono'."
    exit
fi

# Function to load credentials from credentials.yml
load_credentials() {
    HTACCESS_USERNAME=$(grep 'HTACCESS_USERNAME:' /opt/credentials.yml | awk '{print $2}')
    HTACCESS_PASSWORD=$(grep 'HTACCESS_PASSWORD:' /opt/credentials.yml | awk '{print $2}')
    REDIS_PASSWORD=$(grep 'REDIS_PASSWORD:' /opt/credentials.yml | awk '{print $2}')
    MYSQL_NEW_ROOT_PASSWORD=$(grep 'MYSQL_NEW_ROOT_PASSWORD:' /opt/credentials.yml | awk '{print $2}')
    DB_NAME=$(grep 'DB_NAME:' /opt/credentials.yml | awk '{print $2}')
    ADMIN_KEY=$(grep 'ADMIN_KEY:' /opt/credentials.yml | awk '{print $2}')
    CRON_KEY=$(grep 'CRON_KEY:' /opt/credentials.yml | awk '{print $2}')
    ADMIN_USER=$(grep 'ADMIN_USER:' /opt/credentials.yml | awk '{print $2}')
    ADMIN_PASS=$(grep 'ADMIN_USER:' /opt/credentials.yml | awk '{print $2}')
    TWO_FA_SECRET_KEY=$(grep 'TWO_FA_SECRET_KEY:' /opt/credentials.yml | awk '{print $2}')
    REPLICATION_USER_PASSWORD=$(grep 'REPLICATION_USER_PASSWORD:' /opt/credentials.yml | awk '{print $2}')
    domain=$(grep 'DOMAIN:' /opt/credentials.yml | awk '{print $2}')
    master_ip=$(grep 'MASTER_IP:' /opt/credentials.yml | awk '{print $2}')
    slave_ip=$(grep 'SLAVE_IP:' /opt/credentials.yml | awk '{print $2}')
    MEMCACHED_SERVERS=$(grep 'MEMCACHED_SERVERS:' /opt/credentials.yml | awk '{print $2}')
}

# Check if credentials.yml exists
if [ -f /opt/credentials.yml ]; then
    echo "credentials.yml already exists. Using existing credentials."
    load_credentials
    is_single="n"
else
    # Prompt for domain name
    read -p "Please input domain (example: example.com): " domain
    domain=${domain,,} # Convert domain to lowercase
    domain=$(echo "$domain" | sed -e 's/^https:\/\///' -e 's/^www\.//' -e 's/\/$//')

    # Ask if single or multi-server setup
    read -p "Is this a single server setup? (y/n): " is_single
    is_single=${is_single,,} # Convert to lowercase

    if [ "$is_single" != "y" ]; then
        read -p "Enter MariaDB master server IP: " master_ip
        read -p "Enter MariaDB slave server IP: " slave_ip
        
        # Automatically configure memcached servers using master and slave IPs
        MEMCACHED_SERVERS="${master_ip}:11211,${slave_ip}:11211"
    fi

    # Step 0: Create random credentials
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
    REPLICATION_USER_PASSWORD=$(openssl rand -base64 32 | tr -d '+/=')

    # Others required for 2nd step
    DB_NAME="DBN_$(generate_password 16)"
    ADMIN_KEY="AK_$(generate_password 42)"
    CRON_KEY="CK_$(generate_password 40)"

    # to db update later
    ADMIN_USER="AU_$(generate_password 11)"
    ADMIN_PASS="AP_$(generate_password 40)"
    TWO_FA_SECRET_KEY=$(generate_2fa_secret_key)

    cd /opt/
    # Save credentials to a YAML file
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
REPLICATION_USER_PASSWORD: $REPLICATION_USER_PASSWORD
DOMAIN: $domain
EOF
    if [ "$is_single" != "y" ]; then
        echo "MASTER_IP: $master_ip" >> credentials.yml
        echo "SLAVE_IP: $slave_ip" >> credentials.yml
        echo "MEMCACHED_SERVERS: $MEMCACHED_SERVERS" >> credentials.yml
    fi
    echo "Credentials have been saved to credentials.yml."
fi

# Step 1: Install OneInStack
cd /opt/ && wget -c http://mirrors.oneinstack.com/oneinstack-full.tar.gz && tar xzf oneinstack-full.tar.gz && ./oneinstack/install.sh --nginx_option 1 --apache --apache_mpm_option 1 --apache_mode_option 1 --php_option 9 --phpcache_option 1 --php_extensions fileinfo,redis,swoole,memcached --phpmyadmin --db_option 5 --dbinstallmethod 1 --dbrootpwd $MYSQL_NEW_ROOT_PASSWORD --redis --memcached 

# Step 2: Modify php.ini
sed -i '/disable_functions/s/exec,//' /usr/local/php/etc/php.ini
sed -i '/disable_functions/s/stream_socket_server,//' /usr/local/php/etc/php.ini
service php-fpm restart

# Step 3: Install GMP extension
cd /opt/oneinstack/src || exit
tar xzf php-7.4.33.tar.gz
cd php-7.4.33/ext/gmp || exit
apt install libgmp-dev -y
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config
make && make install
echo 'extension=gmp.so' > /usr/local/php/etc/php.d/gmp.ini
service php-fpm restart
echo "GMP extension installation is complete."

# Step 4: Configure MySQL Master-Slave Replication
if [ "$is_single" != "y" ]; then
    # Master Server Configuration
    if [ "$master_ip" == "$(hostname -I | awk '{print $1}')" ]; then
        # Configure master
        sed -i '/\[mariadb\]/a log_bin\nserver_id=1\nbinlog_format=mixed\nlog-basename=master1' /etc/my.cnf
        systemctl restart mariadb
        
        # Create replication user with SSL requirement
        mysql -e "CREATE USER 'replication_user'@'$slave_ip' IDENTIFIED BY '$REPLICATION_USER_PASSWORD';"
        mysql -e "GRANT REPLICATION SLAVE ON *.* TO 'replication_user'@'$slave_ip';"
        mysql -e "FLUSH PRIVILEGES;"
        
        # Get master status
        MASTER_LOG_FILE=$(mysql -e "SHOW MASTER STATUS;" | awk '{print $1}')
        MASTER_LOG_POS=$(mysql -e "SHOW MASTER STATUS;" | awk '{print $2}')
        
        # Save master status to credentials.yml
        sed -i "/MYSQL_NEW_ROOT_PASSWORD/a MASTER_LOG_FILE: $MASTER_LOG_FILE" /opt/credentials.yml
        sed -i "/MASTER_LOG_FILE/a MASTER_LOG_POS: $MASTER_LOG_POS" /opt/credentials.yml
        
        # Configure SSL for replication
        mysql -e "CREATE SSL CERTIFICATE IF NOT EXISTS 'replication_ssl' IDENTIFIED BY '$REPLICATION_USER_PASSWORD';"
        mysql -e "GRANT REPLICATION SLAVE ON *.* TO 'replication_user'@'$slave_ip' REQUIRE SSL;"
    fi
    
    # Slave Server Configuration
    if [ "$slave_ip" == "$(hostname -I | awk '{print $1}')" ]; then
        # Configure slave
        sed -i '/\[mariadb\]/a server_id=2' /etc/my.cnf
        systemctl restart mariadb
        
        # Configure replication with SSL
        mysql -e "CHANGE MASTER TO MASTER_HOST='$master_ip', MASTER_USER='replication_user', MASTER_PASSWORD='$REPLICATION_USER_PASSWORD', MASTER_LOG_FILE='$MASTER_LOG_FILE', MASTER_LOG_POS=$MASTER_LOG_POS, MASTER_SSL=1;"
        mysql -e "START SLAVE;"
        
        # Verify replication status
        mysql -e "SHOW SLAVE STATUS\G" | grep -e "Slave_IO_Running" -e "Slave_SQL_Running"
    fi
fi

# Step 5: Setup .htaccess authentication
HTPASSWD_DIR="/usr/local/apache"
HTPASSWD_FILE="$HTPASSWD_DIR/.htpasswd"
PROTECTED_DIR="/data/wwwroot/default"

if [ ! -d $HTPASSWD_DIR ]; then
    mkdir -p $HTPASSWD_DIR
fi

/usr/local/apache/bin/htpasswd -cb $HTPASSWD_FILE $HTACCESS_USERNAME $HTACCESS_PASSWORD
echo "AuthType Basic
AuthName \"Restricted Access\"
AuthUserFile $HTPASSWD_FILE
Require valid-user" > $PROTECTED_DIR/.htaccess
service httpd restart

# Step 6: Configure Redis for memory caching across servers
# Configure Redis to listen on all interfaces
sed -i 's/bind 127.0.0.1/bind 0.0.0.0/' /usr/local/redis/etc/redis.conf

# Set up authentication
sed -i "s/^# requirepass foobared/requirepass $REDIS_PASSWORD/" /usr/local/redis/etc/redis.conf

# Restart Redis service
systemctl restart redis-server

# Step 7: Configure Memcached for session storage
if ! command -v memcached &> /dev/null; then
    echo "Installing memcached..."
    sudo apt-get install -y memcached
fi

sed -i 's/-l 127.0.0.1/-l 0.0.0.0/' /etc/memcached.conf
service memcached restart

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

service php-fpm restart

# Print credentials
echo "MySQL Root Password: $MYSQL_NEW_ROOT_PASSWORD"
echo "Redis Password: $REDIS_PASSWORD"
echo ".htaccess Username: $HTACCESS_USERNAME"
echo ".htaccess Password: $HTACCESS_PASSWORD"
if [ "$is_single" != "y" ]; then
    echo "MariaDB Master IP: $master_ip"
    echo "MariaDB Slave IP: $slave_ip"
    echo "Replication User Password: $REPLICATION_USER_PASSWORD"
    echo "Master Log File: $MASTER_LOG_FILE"
    echo "Master Log Position: $MASTER_LOG_POS"
    echo "Memcached Servers: $MEMCACHED_SERVERS"
fi
