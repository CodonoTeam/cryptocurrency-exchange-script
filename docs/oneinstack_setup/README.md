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
chmod +x run1_all_in_onestack_setup.sh &&
chmod +x run2_domain_and_unzip.sh &&
chmod +x run3_config_part.sh &&
```

Step 3.
Run step by step
```
cd /opt/
./run1_all_in_onestack_setup.sh
```

Step 4.
Run step by step
```
cd /opt/
./run2_domain_and_unzip.sh
```


Step 5.
Run step by step
```
cd /opt/
./run3_config_part.sh
```
