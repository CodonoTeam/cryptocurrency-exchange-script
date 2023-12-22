
```markdown
# MySQL Setup with OneInStack on Codono.com

This guide walks you through setting up MySQL with OneInStack on Codono.com. Once the setup is complete, you'll need to securely store a MySQL password for future use.

## Step 1: Change MySQL Password

1. Reset the MySQL root password to a strong password (`YOUR_STRONG_PASSWORD`):

    ```bash
    cd /opt/oneinstack
    ./reset_db_root_password.sh
    ```

2. Edit the MySQL configuration file:

    ```bash
    sudo nano /etc/my.cnf
    ```

3. Locate the following line:

    ```
    bind-address = 0.0.0.0
    ```

4. Replace it with the localhost IP:

    ```conf
    bind-address = 127.0.0.1
    ```

## Step 2: Restart MySQL Server

After updating the bind-address, restart the MySQL server for the changes to take effect:

```bash
sudo systemctl restart mysql
```

## Step 3: Check MySQL Server Status

To verify that MySQL is running correctly:

```bash
sudo systemctl status mysql
```

## Important Notes

- **Keep the MySQL Password Secure:** Store the `YOUR_STRONG_PASSWORD` in a secure location. You will need to use this password in your application's configuration file, such as `codebase/pure_config.php`.
- **Updating Application Configuration:** Ensure that the new MySQL password is updated in your application's configuration file to maintain connectivity with the MySQL server.

For more detailed guidance and tips, visit [Codono.com](https://codono.com).

---
```

