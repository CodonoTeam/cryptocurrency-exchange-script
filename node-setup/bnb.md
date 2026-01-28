

```markdown
# Become Root
```bash
sudo su
```

# Create GETH User
```bash
sudo useradd -m geth
```

# Switch To The New User's Home
```bash
cd /home/geth
```

# Download The GETH
```bash
wget https://github.com/bnb-chain/bsc/releases/download/v1.1.11/geth_linux
chmod +x geth_linux
```

# Install Unzip
```bash
apt install unzip
```

# Download Mainnet Configs
```bash
wget https://github.com/bnb-chain/bsc/releases/download/v1.1.11/mainnet.zip
unzip mainnet.zip
./geth_linux --datadir mainnet init genesis.json
```

# Create `start.sh` and `console.sh`
```bash
echo './geth_linux --config ./config.toml --datadir /home/geth/mainnet  --port 5432  --http --http.addr "127.0.0.1"  --http.port "7005" --http.api "personal,eth,net,web3" --allow-insecure-unlock --syncmode "snap" --maxpeers "0"' > start.sh
chmod +x start.sh

echo './geth_linux attach ipc:mainnet/geth.ipc' > console.sh
chmod +x console.sh

echo './geth_linux --datadir ./mainnet "$@"' > cli.sh
chmod +x cli.sh
```

# Setup systemd
```bash
sudo nano /lib/systemd/system/geth.service
```

```
[Unit]
Description=BSC NoSync Node [Does not connect with network of BNB]

[Service]
User=geth
Type=simple
WorkingDirectory=/home/geth
ExecStart=/bin/bash /home/geth/start.sh
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
```

After that:

```bash
chown -R geth.geth /home/geth/*
systemctl enable geth
systemctl start geth
```

# Show logs
```bash
tail -f /home/geth/mainnet/bsc.log
journalctl -f -u geth
```

# Check info of node
```bash
./console.sh
```

# CLI Usages
```bash
./cli.sh account new
./cli.sh account list
```

# Securing Node
```
Create alpha numeric strings from here  [Do not use Special chars Please]
1. 24 chars long  nginx username
2. 32 chars long  nginx password
3. 32 chars long first account password

NGINXUSER:DUJvhuHoOcyI3IGMzappo1LTkV1v7FzJ
NGINXPASS:t2h6G3g4YTc7DS93ullowWr7XPP9ZJBZ
MAINACCOUNTPASS:44ufj5MgOmKTH94ZZQ3WOmSoxkU4zqaN
```

# Creating First account
```
./console.sh

then type 

personal.newAccount()
It would ask for 

passPhrase:
Repeast Password:

Your new account is locked with a password. Please give a password. Do not forget this password.
Enter your first account pass

Password:MAINACCOUNTPASS
Repeat Password:MAINACCOUNTPASS

Result
Public address of the key:   0xF124634534656355456453665436544365
Path of the secret key file: mainnet/keystore/UTC--2021-08-27T06-46-38.255700718Z--F124634534656355456453665436544365

- You can share your public address with anyone. Others need it to interact with you.
- You must NEVER share the secret key with anyone! The key controls access to your funds!
- You must BACKUP your key file! Without the key, it's impossible to access account funds!
- You must REMEMBER your password! Without the password, it's impossible to decrypt the key!
```

# Cross Checking if password you entered is correct [its must to avoid losing funds]
```
> personal.unlockAccount("0xF124634534656355456453665436544365")
Unlock account 0xF124634534656355456453665436544365
Passphrase:MAINACCOUNTPASS
true
```
When it says true, then it means the password is correct.

Now backup the following file [This is a JSON file]:
```
mainnet/keystore/UTC--2021-08-27T06-46-38.255700718Z--F124634534656355456453665436544365
```

and save your password for the first account somewhere safe.

# Nginx Security Installation
Installing nginx on Ubuntu 20 ref: https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-20-04

```bash
sudo apt update
sudo apt install nginx
systemctl status nginx
```

Adjust the firewall to allow only the IP of nginx from your reliable IP.

```bash
sudo sh -c "echo -n 'NGINXUSER:' >> /etc/nginx/.htpasswd"
sudo sh -c "openssl passwd -apr1 >> /etc/nginx/.htpasswd"
```

Password for nginx = NGINXPASS

Edit nginx configuration:

```bash
sudo nano /etc/nginx/sites-available/default
```

Add the following configuration:

```
server {
 listen 9150;
 listen [::]:9150;
 auth_basic "No Access";
 auth_basic_user_file /etc/nginx/.htpasswd;
 location / {
      proxy_pass http://localhost:7005/;
      proxy_set_header Host $host;
 }
}
```

Reload nginx:

```bash
sudo service nginx reload
```
