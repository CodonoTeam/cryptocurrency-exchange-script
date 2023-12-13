ma# Become Root
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

# Download The GETH
```

wget https://gethstore.blob.core.windows.net/builds/geth-linux-amd64-1.10.19-23bee162.tar.gz
tar -xvf geth-linux-amd64-1.10.19-23bee162.tar.gz
mv geth-linux-amd64-1.10.19-23bee162/geth /home/geth/
chmod +x geth
```

# Create `start.sh` and `console.sh`
```
./geth dumpconfig > config.toml
echo "./geth --config ./config.toml --datadir /home/geth/mainnet  --port 5432  --http --http.addr "127.0.0.1"  --http.port "7005" --http.api "personal,eth,net,web3" --allow-insecure-unlock" --syncmode "snap" > start.sh
chmod +x start.sh

echo "./geth attach ipc:/home/geth/mainnet/geth.ipc" > console.sh
chmod +x console.sh

echo "./geth --datadir /home/geth/mainnet "$@"" > cli.sh
chmod +x cli.sh
```

# Additional Layer of security
You can turn off syncing by --maxpeers 0 to start.sh
```
./geth --config ./config.toml --datadir /home/geth/mainnet  --port 5432  --http --http.addr "127.0.0.1"  --http.port "7005" --http.api "personal,eth,net,web3" --allow-insecure-unlock" --syncmode "snap" --maxpeers 0
```
Also on geth server you can use ufw firewall

and allow following port 22, 9150
```
sudo ufw status 
```
Enabling ports
```
sudo ufw allow 22
sudo ufw allow from 123.456.789.000 to any port 9150
```

Here replace your IP which will connect to geth with above IP 123.456.789.000

#Enabliging ufw [If inactive]
```
sudo ufw enable
```


# Setup systemd
```
sudo nano /lib/systemd/system/geth.service
```

Then paste the following;

```
[Unit]
Description=ETH SNAP Node

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
# Check live logs of geth

```
journalctl -f -u geth

```

# Check info of node
```
./console.sh
```
# CLI Usages

```

./cli.sh account new
./cli.sh account list

```
# Securing Node
```
Create alpha numeric strings from here [Do not use Special chars Please]
1. 24 chars long  nginx username
2. 32 chars long  nginx password
3. 32 chars long first account password

nginx user:DUJvhuHoOcyI3IGMzappo1LTkV1v7FzJ
nginx Pass:t2h6G3g4YTc7DS93ullowWr7XPP9ZJBZ
first account pass:44ufj5MgOmKTH94ZZQ3WOmSoxkU4zqaN
```
# Creating First account
```
./cli.sh account new

Or 

./console.sh

then type 

 personal.newAccount()
passPhrase:
Repeast Password:
prompt will ask
Your new account is locked with a password. Please give a password. Do not forget this password.
Enter your first account pass
Password:44ufj5MgOmKTH94ZZQ3WOmSoxkU4zqaN
Repeat Password:44ufj5MgOmKTH94ZZQ3WOmSoxkU4zqaN

Result
Public address of the key:   0xF124634534656355456453665436544365
Path of the secret key file: mainnet/keystore/UTC--2021-08-27T06-46-38.255700718Z--F124634534656355456453665436544365

- You can share your public address with anyone. Others need it to interact with you.
- You must NEVER share the secret key with anyone! The key controls access to your funds!
- You must BACKUP your key file! Without the key, it's impossible to access account funds!
- You must REMEMBER your password! Without the password, it's impossible to decrypt the key!
```
Cross Checking if password you entered is correct [its must to avoid loosing funds]

> personal.unlockAccount("0xF124634534656355456453665436544365")
Unlock account 0xF124634534656355456453665436544365
Passphrase:44ufj5MgOmKTH94ZZQ3WOmSoxkU4zqaN
true

When it says true then it means password is correct .

@todo 
Now backup following file [This is a json file ]

mainnet/keystore/UTC--2021-08-27T06-46-38.255700718Z--F124634534656355456453665436544365

and save your password for first account somewhere same.

# Nginx Security Installation
```
Installing nginx on Ubuntu 20 ref: https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-20-04
sudo apt update
sudo apt install nginx
systemctl status nginx

@todo adjust firewall to allow ip of nginx from only your reliable ip

sudo sh -c "echo -n 'DUJvhuHoOcyI3IGMzappo1LTkV1v7FzJ:' >> /etc/nginx/.htpasswd"


sudo sh -c "openssl passwd -apr1 >> /etc/nginx/.htpasswd"

password for nginx=t2h6G3g4YTc7DS93ullowWr7XPP9ZJBZ


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

#Run 2 more commands to check if everything is good.
```
sudo service nginx reload
sudo service nginx status
```
