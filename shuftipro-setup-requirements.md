#[Crypto Exchange Script](https://codono.com)
In case of Firewall or Cloudflare
Allow following IPS

#Whitelist the following IPs to receive a callback.
﻿```
﻿IPv4 : 85.10.199.216
IPv6 : 2a01:4f8:a0:53ad::2
IPv4 : 78.46.100.11
IPv6 : 2a01:4f8:120:9365::2
﻿```
 
﻿#New IPs to whitelist:
﻿```
﻿IP1: IPV4=>65.108.103.45
IPV6=> 2a01:4f9:6b:1a8d::2
IP2: IPV4=>142.132.144.101
IPV6=> 2a01:4f8:261:164e::2
```

#Cloudflare Rule
```
(ip.src eq 85.10.199.216) or (ip.src eq 2a01:4f8:a0:53ad::2) or (ip.src eq 78.46.100.11) or (ip.src eq 2a01:4f8:120:9365::2) or (ip.src eq 65.108.103.45) or (ip.src eq 2a01:4f9:6b:1a8d::2) or (ip.src eq 142.132.144.101) or (ip.src eq 2a01:4f8:261:164e::2)
```
