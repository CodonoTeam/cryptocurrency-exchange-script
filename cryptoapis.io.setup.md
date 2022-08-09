#Codono [CryptoApis Script](https://codono.com/features/) [With Ultra and Zues]
You must have following 
```
Step 1. Login to https://my.cryptoapis.io/  Create new api . Enable it and Give all route permissions. [Save api_key in Notepad]
Step 2. Create new wallet in Dashbaoard of Cryptoapis.Goto Dashbaoard of Cryptoapis -> Goto My Wallet-> New mainet wallet -> [Save WalletId in Notepad] 
Step 3. [Only for ethereum] Create a new ethereum account -> Goto Dashbaoard of Cryptoapis -> Goto My Wallet-> Addresses -> New deposit address [Label:mainAccount, Blockchain Protocol: Ethereum,Network:mainnet] -> Save Address to notepad
```
Adding Ethereum
```
Symbol :eth
Title: Ethereum
CoinType: CryptoApis
Token of :none
Network:mainnet

Walletid:WalletID saved in step2
Contract Address:Leave Blank
API Key: Api_key saved in step1
Main Account :mainAccount saved in step 3
Block Explorer : https://etherscan.io/tx/
Decimals: 8
```

Adding Bitcoin
```
Symbol :btc
Title: Bitcoin
CoinType: CryptoApis

Network Type:mainnet

Walletid:WalletID saved in step2
Contract Address:Leave Blank
API Key: Api_key saved in step1
Main Account :Leave Blank
Block Explorer : https://www.blockchain.com/btc/tx/
Decimals: 8
```

IPN Generated URL
```
https://yoursite.com/IPN/callback_cryptoapis
```
Note: Your website must run on https [ssl] in order to support callback.

Cron URL

Run in every 10 mins max [ as it costs 6 CryptoAPIs api Request Quota]  [Economics 1 request per 10 mins , 6 Requests per hour , 24*6 request per day . So total spend=6*24*6=864 ]
```
https://yoursite.com/Coin/deposit_cryptoapis/securecode/cronkey
```


Step 6. in Step 5 you selected default coin and its network , now you can create coin and Token on same network to sell it against token using -> Admin-> Trade-> Dex->Dex Coins

Add or Edit


```
Status:	Enabled [Coin status]
Is Default In Spend:	NA [Select only one coin as default status either ETH or BNB]
Is Token?:	Token [Only One main coin]
Name Of Coin:	DAI [Name of coin]
Symbol Of Coin:	dai [symbol in small letters ie : usdt]
Image :	Click Add Picture 80px*80px
Contract Address :	0xad6d458402f60fd3bd25163575031acdce07538d [Contract Address of token , Empty in case of main coin]
Decimals:	18 [Only One main coin]
Price :	0.01010000[Price of your token]
Min Buy Quantity :	0.01000000 [Minimum Buy Quantity]
Max Buy Quantity :	10000.00000000
```
