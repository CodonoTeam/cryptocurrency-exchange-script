#Tron Code is In Built in [Codono Ultra](https://codono.com/product/ultra).

It does not require any additional Coin node .

Setup instructions for [cryptocurrency exchange script](https://codono.com/).

Generating Main Tron account where all user deposits will Move to.

You can generate Main account externally or by running following url
```
yoursite.com/Tron/makeOneAccount/securecode/cronkey
```
It would give you following type of information

This informationation on refresh will vanish , it does not get saved anywhere.If you plan to use this account as Main account ,Save this information some where safe, print it and keep safe
```
Array
(
    [private_key] => xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    [public_key] => 0442281c4a2fb2e58f57bbb42f8d2b0ac00252aee341fdae45f05748d4fc2e2e83e8bb8e872da8157b7258cd09aa0c35d404d568bce1430398ef7e88eb6e6674b8
    [address_hex] => 41f8cbbde4e0433333f2ea1bbedf0647447a5fa9f8
    [address_base58] => TYeieronBA8hbbUpW7fekUqjdUQdmR78oX
)
```
This is just a tool to generate unique Tron address along with its private keys, You can use this account or generate somewhere else and save it in tron config in admin area, This informationation on refresh will vanish , it does not get saved anywhere.

Now goto -> Admin-> Coin-> Find trx or Add new [If not exists]
```
symbol:trx
parent symbol:trx
frontend title:Tron [Trc20]
Coin Type:Tron Network [Trc20]
Token of :none
Wallet Server IP :  [Keep Empty]
Wallet Server Port :  [Keep Empty]
Keep Empty:  [Keep Empty]
Server Username:[Keep Empty]
Wallet Server Password: [private_key generated from above step
Main Account:  [address_base58 value from above step]
Block Explorer:https://tronscan.org/#/transaction/
Decimal:6
```
 
Adding TRC20 [Example of USDT https://tronscan.io/#/token20/TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t]
```
symbol:tusdt [see here its unique key for symbol]
parent symbol:usdt [this is main coin symbol where it falls into]
frontend title:USDT [Trc20]
Coin Type:Tron Network [Trc20]
Token of :trx
Wallet Server IP :  [Keep Empty]
Wallet Server Port :  [Keep Empty]
Keep Empty:  [Keep Empty]
Server Username:TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t [contract address ]
Wallet Server Password: [private_key generated from above step
Main Account:  [address_base58 value from above step]
Block Explorer:https://tronscan.org/#/transaction/
Decimal:6
```


Deposit cron: Run every min
```
https://yoursite.com/Tron/cronDeposits/securecode/cronkey
```

Moving Token to main account [Example USDT]
```
https://yoursite.com/Tron/moveTokenToMain/securecode/cronkey/token/usdt
```

Moving Tron to main account [Example USDT]
```
https://yoursite.com/Tron/moveTronToMain/securecode/cronkey/
```



Saving ABI file [ For each token]

Goto Token code page on tronscan

Example
```
https://tronscan.io/#/token20/TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t/code
```
Copy Contract ABI


and save in following location -> Public/ABI

File name example [Capital name]

USDT.abi
UNI.abi
