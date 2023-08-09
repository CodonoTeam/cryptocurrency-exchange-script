## Codono Installation Setup Tutorial

To set up Codono on your server, follow these steps:

### Step 1: Download Codono

1. Download the Codono zip file from the provided download link.
2. Extract the contents to your preferred directory.

### Step 2: Edit `pure_config.php`

1. Open the `pure_config.php` file in a text editor.
2. Modify the necessary configurations, such as `SITE_URL`, `DB_HOST`, `DB_NAME`, and others.

### Step 3: Configure Database Settings

1. Set the database connection parameters according to your database setup in the `pure_config.php` file.

Example:
```php
const DB_TYPE = 'mysql';
const DB_HOST = '127.0.0.1';
const DB_NAME = 'codonoexchange';
const DB_USER = 'root';
const DB_PWD = '';
const DB_PORT = '3306';
```

### Step 4: Configure Other Settings

In this step, review and adjust other settings in the `pure_config.php` file based on your specific requirements. Here are some of the key settings you might want to consider:

- `APP_DEMO`: Set this to `0` to run Codono in production mode. If set to `1`, Codono will run in DEMO mode.
- `MOBILE_CODE`: Set this to `0` to enable SMS authentication. Setting it to `1` will bypass SMS authentication (risky).
- `MOBILE_LAUNCHED`: Set this to `1` if you want to integrate and enable MOBILE APP LOGIN.
- `ENABLE_MOBILE_VERIFY`: Set this to `1` to enable mobile verification.
- `M_ONLY`: Set this to `0` to allow users without SMS verification to use the system. Setting it to `1` will restrict the system to only users with SMS verification.
- `M_DEBUG`: Set this to `0` for production mode. If set to `1`, it enables site-wide debugging (not recommended for production).
- `ADMIN_DEBUG`: Set this to `0` for production mode. If set to `1`, it enables full debugging for the admin.
- `DEBUG_WINDOW`: Set this to `0` for production mode. If set to `1`, it shows a debug window on every page.
- `KYC_OPTIONAL`: Set this to `0` to turn on KYC on user signup and make it optional. If set to `1`, KYC will be optional during signup.
- `ENFORCE_KYC`: Set this to `0` to allow users without KYC to withdraw and trade. If set to `1`, only users with KYC will be able to withdraw and trade.
- `ADMIN_KEY`: Set this to alphanumeric minimum 16-32 char for keeping your admin URL secure
- `CRON_KEY`: Set this to alphanumeric minimum 16-20 char for keeping your Cron URL secure

Make sure to save the `pure_config.php` file after making the necessary changes.


Example Admin URL after `ADMIN_KEY` is set
```
http://exchange.local/Admin/Login/index/securecode/securekey
```
Complete Cronlist here 
```
http://exchange.local/Admin/Login/index/securecode/securekey
```

**Note:** Review all other settings in the file carefully and update them based on your specific requirements.

### Step 5: Set Up Redis Caching (Optional but Recommended)

Codono supports Redis caching for improved performance. To enable Redis caching, follow these steps:

1. Ensure that you have Redis installed on your server. If not, install Redis by referring to the official Redis documentation for your operating system.

2. In the `pure_config.php` file, set the `REDIS_ENABLED` constant to `1` to enable Redis caching.

3. Set the `REDIS_PASSWORD` constant to your Redis password. If you haven't set a password for your Redis instance, leave the value as an empty string (`''`).

```php
// Enable Redis caching (1 for enabled, 0 for disabled)
const REDIS_ENABLED = 1; 

// Set this as your Redis password
const REDIS_PASSWORD = 'your_redis_password_here';
```

4. Save the changes to `pure_config.php`.

### Step 6: Configure PHP Extensions

Codono requires specific PHP extensions to be installed and enabled. Ensure you have the following PHP extensions enabled in your `php.ini` configuration file:

```ini
extension=exec
extension=openssl
extension=redis
extension=pdo_mysql
extension=mbstring
extension=curl
extension=tokenizer
extension=xml
extension=fileinfo
extension=ctype
extension=json
extension=bcmath
extension=zip
extension=gd
extension=allow_url_fopen
extension=iconv
extension=libsodium
extension=stream_socket_server
```

Please note that the exact method of enabling PHP extensions may vary depending on your server environment. After making changes to the `php.ini` file, remember to restart your web server for the changes to take effect.

### Step 7: Prepare the Codono Files

1. Extract the contents of the downloaded ZIP file to your web server's document root or the desired directory.

2. Ensure that the web server has proper read and write permissions for the Codono files and directories.

### Step 8: Set Up the Database

1. Create a new database for Codono in your MariaDB environment. You can do this using a graphical tool like phpMyAdmin or the MySQL command line.

2. Open the `pure_config.php` file and fill in the database connection details:

```php
// Database Type
const DB_TYPE = 'mysql';
// DB Host
const DB_HOST = 'your_database_host'; // Usually 'localhost'
// DB Name
const DB_NAME = 'your_database_name';
// DB User
const DB_USER = 'your_database_username';
// DB PASSWORD
const DB_PWD = 'your_database_password';
// DB PORT (If not sure, leave it as default)
const DB_PORT = '3306';
```

3. Save the changes to `pure_config.php`.
   
4. Import codonoexchange_x.sql to your_database_name. 
### Step 9: Connect Required Nodes

You would need to setup coin nodes or thirdparty services to setup wallet system on exchange . Please refer to Docuemntation for Coin nodes setup.

### Step 10: Perform the Installation

1. Open your web browser and navigate to the URL where you placed the Codono files.

2. Goto exchange.local/install_check.php to see if all requirements are met.

3. Once the installation is complete, remove the `install_check.php` file.
4. Setup all crons by visiting this link http://exchange.local/Cronlist/index/securecode/cronkey
5. You can now visit exchange.local

### Step 11: Test Your Exchange

Congratulations! Your Codono exchange is now set up and ready to go. Test various functionalities, including user registration, trading, deposits, withdrawals, and admin features, to ensure everything works as expected.

Please remember to keep your server and Codono installation secure by regularly updating software, using strong passwords, and following other security best practices.
### Additional Tutorials:

- [Binance Liquidity Setup Tutorial](Binance_Liquidity.txt)
- [Socket Setup for Huobi](socket_for_huobi.txt)
- [Emptying Tables for Fresh System](tables_to_empty_for_fresh_system.txt)
- [ShuftiPro Setup Tutorial](ShuftiPro.txt)
- [Binance Client Info Setup](bnb_client_info.txt)
- [Crypto APIs Setup Tutorial](cryptoapis_setup.txt)
- [Tron Setup Tutorial](tron_setup.txt)
- [DEX Setup Tutorial](dex_setup.txt)
- [XRP Setup Tutorial](xrp_setup.txt)
- [Google Login Setup Tutorial](google_login_setup.txt)
