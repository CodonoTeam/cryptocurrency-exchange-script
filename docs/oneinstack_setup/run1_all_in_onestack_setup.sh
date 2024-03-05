#!/bin/bash

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

# Prompt user for domain name input
read -p "Please input domain(example: example.com): " domain
domain=${domain,,} # Convert domain to lowercase to avoid issues


# Clean the input: remove https://, www, and trailing slashes
domain=$(echo "$domain" | sed -e 's/^https:\/\///' -e 's/^www\.//' -e 's/\/$//')

# Step 0: Create random credentials
generate_password() {
    local length=$1
    tr -dc A-Za-z0-9 </dev/urandom | head -c ${length} ; echo ''
}
generate_2fa_secret_key() {
    # Generate 10 random bytes
    local random_bytes=$(openssl rand 10)
    # Directly encode these bytes into base32
    local secret_key=$(echo -n "$random_bytes" | base32 | tr -d '=')
    echo "$secret_key"
}


# Generating credentials with prefixes
HTACCESS_USERNAME="HU_$(generate_password 16)"
HTACCESS_PASSWORD="HP_$(generate_password 32)"
REDIS_PASSWORD="RP_$(generate_password 40)"
MYSQL_NEW_ROOT_PASSWORD="MP_$(generate_password 40)"

# Others required for 2nd step
DB_NAME="DBN_$(generate_password 16)"
ADMIN_KEY="AK_$(generate_password 42)"
CRON_KEY="CK_$(generate_password 40)"

# to db update later
ADMIN_USER="AU_$(generate_password 20)"
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
DOMAIN: $domain
EOF
echo "Credentials have been saved to credentials.yml too"

# Step 1: Install OneInStack
cd /opt/ && wget -c http://mirrors.oneinstack.com/oneinstack-full.tar.gz && tar xzf oneinstack-full.tar.gz && ./oneinstack/install.sh --nginx_option 1 --apache  --apache_mpm_option 1 --apache_mode_option 1 --php_option 9 --phpcache_option 1 --php_extensions fileinfo,redis,swoole --phpmyadmin  --db_option 5 --dbinstallmethod 1 --dbrootpwd $MYSQL_NEW_ROOT_PASSWORD --redis  --memcached 

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

# Step 4: Configure MySQL

cd /opt/oneinstack
sed -i 's/bind-address = 0.0.0.0/bind-address = 127.0.0.1/' /etc/my.cnf
systemctl restart mysql


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

# Step 6: Configure Redis

sed -i "s/# requirepass foobar/requirepass $REDIS_PASSWORD/" /usr/local/redis/etc/redis.conf
service redis-server restart

# Print credentials
echo "MySQL Root Password: $MYSQL_NEW_ROOT_PASSWORD"
echo "Redis Password: $REDIS_PASSWORD"
echo ".htaccess Username: $HTACCESS_USERNAME"
echo ".htaccess Password: $HTACCESS_PASSWORD"
