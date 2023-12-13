# Become Root
```
sudo su
```

# Create GETH User
```
sudo useradd -m geth
```

# Switch To The New User's Home
```
cd /home/geth
```

# Download The Ken CLi
```
wget https://packages.klaytn.net/klaytn/v1.9.0/ken-v1.9.0-0-linux-amd64.tar.gz
tar -xvf ken-v1.9.0-0-linux-amd64.tar.gz
chmod +x ken
```
# Create config.toml 
```
./ken dumpconfig >config.toml
```

# Create `start.sh` and `console.sh`
```
echo "./ken --config ./config.toml --datadir /home/geth/mainnet  --port 5432  --rpc --rpcaddr 127.0.0.1  --rpcport 7005 --rpcapi personal,eth,net,web3 --syncmode snap --nodiscover
> start.sh
chmod +x start.sh

```

# Setup systemd
```
sudo nano /lib/systemd/system/geth.service
```

Then paste the following;

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

After that;

```
chown -R geth.geth /home/geth/*
systemctl enable geth
systemctl start geth
```

# Show logs
```
tail -f /home/geth/mainnet/bsc.log
journalctl -f -u geth
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

 ./ken --datadir ./mainnet account new

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
Cross Checking if password you entered is correct [its must to avoid loosing funds]
```
> personal.unlockAccount("0xF124634534656355456453665436544365")
Unlock account 0xF124634534656355456453665436544365
Passphrase:MAINACCOUNTPASS
true
```
When it says true then it means password is correct .

Now backup following file [This is a json file ]

mainnet/keystore/UTC--2021-08-27T06-46-38.255700718Z--F124634534656355456453665436544365

and save your password for first account somewhere same.


# Nginx Security Installation
```
sudo apt update
sudo apt install nginx
systemctl status nginx
```
@todo adjust firewall to allow ip of nginx from only your reliable ip
```
sudo sh -c "echo -n 'NGINXUSER:' >> /etc/nginx/.htpasswd"


sudo sh -c "openssl passwd -apr1 >> /etc/nginx/.htpasswd"
```
password for nginx=NGINXPASS
``` 
#sudo rm /etc/nginx/sites-available/default
sudo nano /etc/nginx/sites-available/default


server {
 listen 9150;
 listen [::]:9150;
 # ADDED THESE TWO LINES FOR AUTHENTICATION
auth_basic "No Access";
auth_basic_user_file /etc/nginx/.htpasswd; 
 #server_name example.com;
 location / {
      proxy_pass http://localhost:7005/;
      proxy_set_header Host $host;
 }
}
```



sudo service nginx reload
