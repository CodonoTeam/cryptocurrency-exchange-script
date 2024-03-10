*** Step 1
First Upload your zip codono_unpack.zip to /opt folder of server
You can use scp or upload using filezilla
*** Step 2
Run following
```
cd /opt/ &&
wget https://raw.githubusercontent.com/CodonoTeam/cryptocurrency-exchange-script/main/docs/oneinstack_setup/run1_all_in_onestack_setup.sh &&
wget https://raw.githubusercontent.com/CodonoTeam/cryptocurrency-exchange-script/main/docs/oneinstack_setup/run2_domain_and_unzip.sh &&
wget https://raw.githubusercontent.com/CodonoTeam/cryptocurrency-exchange-script/main/docs/oneinstack_setup/run3_config_part.sh &&
wget https://raw.githubusercontent.com/CodonoTeam/cryptocurrency-exchange-script/main/docs/oneinstack_setup/run4_db_create_and_import.sh &&
wget https://raw.githubusercontent.com/CodonoTeam/cryptocurrency-exchange-script/main/docs/oneinstack_setup/run5_websocket.sh &&
chmod +x run1_all_in_onestack_setup.sh &&
chmod +x run2_domain_and_unzip.sh &&
chmod +x run3_config_part.sh &&
chmod +x run4_db_create_and_import.sh &&
chmod +x run5_websocket.sh
```

Step 3.
Environment setup, make sure codono_unpack.zip was uploaded to /opt folder already.
```
cd /opt/
./run1_all_in_onestack_setup.sh
```

Step 4.
Run to create domain directory , unzip code and place them in correct place.
```
cd /opt/
./run2_domain_and_unzip.sh
```


Step 5.
Run to create pure_config update db and other info using credentials.yml.
```
cd /opt/
./run3_config_part.sh
```

Step 6.
Run to create db , import SQL file in it and update admin credentials.
```
cd /opt/
./run4_db_create_and_import.sh
```


Step 7.
Run to start websocket for Liquidity markets
```
cd /opt/
./run5_websocket.sh
```
