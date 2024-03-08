#!/bin/bash

# Read MySQL credentials for codono db and other info from /opt/credentials.yml
MYSQL_ROOT_PASSWORD=$(grep 'MYSQL_NEW_ROOT_PASSWORD:' /opt/credentials.yml | cut -d ' ' -f 2)
DB_NAME=$(grep 'DB_NAME:' /opt/credentials.yml | cut -d ' ' -f 2)
ADMIN_USER=$(grep 'ADMIN_USER:' /opt/credentials.yml | cut -d ' ' -f 2)
ADMIN_PASS=$(grep 'ADMIN_PASS:' /opt/credentials.yml | cut -d ' ' -f 2)
TWO_FA_SECRET_KEY=$(grep 'TWO_FA_SECRET_KEY:' /opt/credentials.yml | cut -d ' ' -f 2)

# Check if DB exists
DB_EXISTS=$(mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "SHOW DATABASES LIKE '$DB_NAME';" | grep "$DB_NAME" > /dev/null; echo "$?")

# If DB does not exist, create it
if [ "$DB_EXISTS" != "0" ]; then
    echo "Database $DB_NAME does not exist. Creating database..."
    mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"
fi

# Import SQL files into the database
for SQL_FILE in /data/wwwroot/codono_unpack/*.sql; do
    echo "Importing $SQL_FILE into $DB_NAME..."
    mysql -uroot -p"$MYSQL_ROOT_PASSWORD" "$DB_NAME" < "$SQL_FILE"
done

# Update codono_admin table
echo "Updating codono_admin table..."
mysql -uroot -p"$MYSQL_ROOT_PASSWORD" "$DB_NAME" -e "
UPDATE codono_admin
SET username = '$ADMIN_USER', 
    password = MD5('$ADMIN_PASS'), 
    ga = '$TWO_FA_SECRET_KEY'
WHERE id = 1;
"

echo "Codono Database setup and updates complete.Please visit https://${DOMAIN}/install_check.php and https://${DOMAIN}/"
