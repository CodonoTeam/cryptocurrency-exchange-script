---

# Redis Setup with OneInStack on Codono.com

This guide walks you through setting up Redis with OneInStack on Codono.com. Once the setup is complete, you'll need to securely store a Redis password for future use.

## Step 1: Change Redis Password

1. Open the Redis configuration file using a text editor (such as nano):

    ```bash
    sudo nano sudo nano /usr/local/redis/etc/redis.conf
    ```

2. Locate the following line in the file:

    ```conf
    # requirepass foobar
    ```

3. Replace it with a strong alphanumeric password of your choice. Uncomment the line by removing the `#` at the beginning:

    ```conf
    requirepass YOUR_STRONG_PASSWORD
    ```

    Replace `YOUR_STRONG_PASSWORD` with your chosen password. Ensure it's a strong, alphanumeric password.

## Step 2: Restart Redis Server

After updating the password, you need to restart the Redis server for the changes to take effect:

```bash
sudo service redis-server restart
```

## Important Notes

- **Keep the Redis Password Secure:** Store the `YOUR_STRONG_PASSWORD` in a secure location. You will need to use this password in your application's configuration file, such as `codebase/pure_config.php`.
- **Updating Application Configuration:** Ensure that the new Redis password is updated in your application's configuration file to maintain connectivity with the Redis server.

For more detailed guidance, visit [Codono.com](https://codono.com).

---
