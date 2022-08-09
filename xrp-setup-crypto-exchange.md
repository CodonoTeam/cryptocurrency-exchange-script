#XRP Code is In Built in [Codono Ultra](https://codono.com/product/ultra) and [Codono Zues](https://codono.com/product/codono-zues/)

It does not require any additional Coin node .

Setup instructions

Generating XRP account where all user deposits automatically be deposited to using their dest_tag

You can generate Main account externally or by running following url
```
https://bithomp.com/paperwallet/
```
Copy the secret and address [ Save it somewhere same]

NOTE: there are various offline and safe methods to generate ripple address and keys , we suggest use them .


Now goto ->Codono Admin-> Coin-> Find xrp or Add new [If not exists]
```
symbol:xrp
parent symbol:xrp [or empty]
frontend title:Ripple [XRP network]
Coin Type:XRP Chain
Token of :none
Wallet Server IP :  [Keep Empty]
Wallet Server Port :  [Keep Empty]
Keep Empty:  [Keep Empty]
Server Username:[Keep Empty]
Wallet Server Password: [secret generated from above step
Main Account:  [address value from above step]
Block Explorer:https://xrpcharts.ripple.com/#/transactions/
Decimal:6
```
 

Deposit cron: Run every min

Yoursite/Coin/xrpdeposit/securecode/cronkey

