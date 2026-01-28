## Disclaimer:

**Before proceeding with the following steps, please ensure that you have a good understanding of the tasks involved. Modifying server configurations and using supervisorctl can have a significant impact on your server, and any incorrect configuration can cause issues. Make sure to have a backup of your system before making any changes.**

### Step 1: Open other_config.php

Open the `other_config.php` file in a text editor.

Make sure the following values are enabled/added:

```php
define('SOCKET_WS_ENABLE', 1); // This Socket server URL
define('SOCKET_WS_URL', "wss://rapid.codono.com/wsocket"); // wss for live sites
```

Change `wss://rapid.codono.com/wsocket` to your own domain or server URL where your WebSocket server will be running.

### Step 2: Enabling Port 7272 for WSS

You would need to enable port 7272 on your server for WebSocket, so the system can broadcast messages and read from it.

### Step 3: Starting Sockets

On the root of your Codono installation, type in the following command to start the socket server:

```bash
php socketbot.php start
```

You can also make it run in the background as a daemon process.

### NGINX Forwarding

Add the following NGINX configuration to forward requests for the `/wsocket` path to the WebSocket server:

```nginx
location ~/wsocket(.*)$ {
    proxy_set_header X-Real-IP  $remote_addr;
    proxy_set_header X-Forwarded-For $remote_addr;
    proxy_set_header Host $host;
    proxy_pass http://127.0.0.1:7272;
}
```

### Step 4: Setting up Socket bot in Supervisorctl to Run Always

1. Make sure supervisor is installed. If not, you can install it using the following command:

```bash
sudo apt-get install supervisor
```

2. Navigate to the supervisor configuration directory:

```bash
cd /etc/supervisor/conf.d/
```

3. Create a new configuration file for the socket bot:

```bash
sudo nano socketbot.conf
```

4. Add the following configuration to the `socketbot.conf` file:

```ini
[program:socketbot]
directory=/data/wwwroot/codebase  ; Replace with your Codono installation directory
command=/usr/local/php/bin/php socketbot.php start
autostart=true
autorestart=true
stderr_logfile=/var/log/supervisor/socketbot.err.log
stdout_logfile=/var/log/supervisor/socketbot.out.log
```

5. Save the file and exit the text editor.

6. Reload supervisorctl to apply the changes:

```bash
supervisorctl reload
```

7. You can now start the socket bot using the following command:

```bash
supervisorctl start socketbot
```

8. To check the status and logs of the socket bot, use the following commands:

```bash
supervisorctl
tail -f /var/log/supervisor/socketbot.out.log
```

Please note that the paths and commands may vary depending on your server environment and Codono installation. Make sure to replace `/data/wwwroot/codebase` with the actual path to your Codono installation and `/usr/local/php/bin/php` with the path to your PHP executable. However its correct if you are following our guide using oneinstack.

Always ensure that you have proper permissions and access rights while making changes to the server configuration. If you are not familiar with these configurations, it's best to consult with a system administrator or expert.
