#[Codono.com](https://codono.com) BEP20 Setup Guide

You will need following information once you are done with setup 
```
WALLETSERVERIP
WALLETSERVERPORT
MAINACCOUNTPWD
MAINACCOUNTADDRESS
```
YOURSITEHERE :Exchange URL
CRONKEYHERE: Secure cron key defined in pure_config.php


For BNB Coin only
```
Symbol :bnb
Title: Binance Coin
CoinType: Esmart
Token of :none
RPC Type:Light
Public RPC URL:https://bsc-dataseed.binance.org/
Wallet Server IP :WALLETSERVERIP
Wallet Server Port:WALLETSERVERPORT
Server Username: EMPTY [Leave Blank only]
Wallet Server Password: [of MAIN ACCOUNT]:MAINACCOUNTPWD
Main Account :MAINACCOUNTADDRESS
Block Explorer : https://bscscan.com/tx/
Decimals: 8
Automatic Withdrawal :0.0001 [Amount that is auto approved for withdrawal without admin concent]
```

Adding BEP20
Goto Contract address on bscscan.com to get detail first [ Example for BUSD ]
https://bscscan.com/token/0xe9e7cea3dedca5984780bafc599bd69add087d56


```
Symbol :busd
Title: Binance-Peg BUSD Token
CoinType: Esmart
Token of :BNB
RPC Type:Light
Public RPC URL:https://bsc-dataseed.binance.org/
Wallet Server IP :WALLETSERVERIP
Wallet Server Port:WALLETSERVERPORT
Server Username: 0xe9e7cea3dedca5984780bafc599bd69add087d56 [get from bscscan.com]
Wallet Server Password: [of MAIN ACCOUNT]:MAINACCOUNTPWD
Main Account :MAINACCOUNTADDRESS
Block Explorer : https://bscscan.com/tx/
Decimals: 18 [get from bscscan.com]
Automatic Withdrawal :0.0001 [Amount that is auto approved for withdrawal without admin concent]
```


A .Deposit Detection [ We have set cron to check every min]

https://YOURSITEHERE/Coin/esmart_deposit/securecode/CRONKEYHERE/chain/bnb

About main account: This is account where all funds would be move to , and from here only all withdrawals will take place.

B. Moving User Token [bep20] to Main account 

/* Note :
Only run manually in browser Address Bar, Moving any token will cost gas [BNB] If user account does not have enough BNB , Then it will extract enough BNB from Main account and send it to user account , When above url run again in browser , user account will have enough gas to move token and Tokens will move to Main account , Since gas price is moderarte on BNB We suggest moving Tokens with higher value . 
*/

https://YOURSITEHERE/Coin/esmart_token_to_main/securecode/CRONKEYHERE/coinname/busd




C. Moving BNB to Main account 

/* Note :
Only run manually in browser Address Bar, Moving any BNB will cost gas [BNB] so main account would receive Balance - Gas  . 
*/

https://YOURSITEHERE/Coin/esmart_to_main/securecode/CRONKEYHERE/coin/bnb



Importing Main account into Metamask->
Download your Main account Keystore file from /home/geth/mainnet/keystore/ UTC ... address of mainaccount

Then follow this tutorial to import wallet to metamask [Step2 ]
https://medium.com/publicaio/how-import-a-wallet-to-your-metamask-account-dcaba25e558d#3ec7
