#!/bin/bash

# Step 0: Create random credentials

HTACCESS_USERNAME=$(generate_password 16)
HTACCESS_PASSWORD=$(generate_password 32)
REDIS_PASSWORD=$(generate_password 40)
MYSQL_NEW_ROOT_PASSWORD=$(generate_password 40)

# Step 1: Install OneInStack
cd /opt/ && wget -c http://mirrors.oneinstack.com/oneinstack-full.tar.gz && tar xzf oneinstack-full.tar.gz && ./oneinstack/install.sh --nginx_option 1 --php_option 9 --phpcache_option 1 --php_extensions fileinfo,redis,swoole --phpmyadmin --db_option 5 --dbinstallmethod 1 --dbrootpwd $MYSQL_NEW_ROOT_PASSWORD --redis --reboot

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
systemctl status mysql

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
