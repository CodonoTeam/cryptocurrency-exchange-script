#!/bin/bash

# Navigate to the OneinStack source directory
cd /opt/oneinstack/src || exit

# Decompress the corresponding version of the PHP installation package
tar xzf php-7.4.33.tar.gz

# Enter the corresponding extension directory
cd php-7.4.33/ext/gmp || exit

# Install libgmp development package
apt install libgmp-dev -y

# Prepare the PHP extension for compiling
/usr/local/php/bin/phpize

# Configure the extension to use the correct php-config
./configure --with-php-config=/usr/local/php/bin/php-config

# Compile and install the extension
make && make install

# Add the extension to PHP's configuration
echo 'extension=gmp.so' > /usr/local/php/etc/php.d/gmp.ini

# Restart PHP-FPM to load the new extension
service php-fpm restart

echo "GMP extension installation is complete on your OneInStack PHP 7.4 stack."
