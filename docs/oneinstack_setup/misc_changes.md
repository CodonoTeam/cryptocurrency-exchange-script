# Misc Changes with OneInStack on Codono.com

This guide walks you through changing php.ini and few other part . 

## Step 1: Visit /install_check.php

1. Goto your website and visit link yoursite

    ```
	https://yoursite.com/install_check.php
    ```

2. Note down deficiencies 


## Step 2: php.ini changes for allowing exec, stream_socket_server functions

Goto CLI and type

```bash
sudo nano /usr/local/php/etc/php.ini
```
Then press ctrl+w and type disable_functions 

from there remove these two function names

```
exec
stream_socket_server
```
Save the file with ctrl+o then exit


## Step 3: Change Path of php in pure_config.php


Open codebase/pure_config.php and find

```
const PHP_PATH = 'php';
```
Replace with 

```
const PHP_PATH = '/usr/local/php/bin/php';
```
## Step 4: Restart


Now need to restart PHP-FPM

```
service php-fpm restart
```
## Important Notes

- ** Visit install_check.php and find if any deficiencies

For more detailed guidance and tips, visit [Codono.com](https://codono.com).

---
```

