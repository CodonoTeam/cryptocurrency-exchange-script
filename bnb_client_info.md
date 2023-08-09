## Wallet Configuration for BNB Coin

### Symbol: bnb
- Title: Binance Coin
- CoinType: Esmart
- Token of: none
- RPC Type: Light
- Public RPC URL: [https://bsc-dataseed.binance.org/](https://bsc-dataseed.binance.org/)
- Wallet Server IP: WALLETSERVERIP
- Wallet Server Port: WALLETSERVERPORT
- Server Username: [Leave Blank only]
- Wallet Server Password: [of MAIN ACCOUNT]: MAINACCOUNTPWD
- Main Account: MAINACCOUNTADDRESS
- Block Explorer: [https://bscscan.com/tx/](https://bscscan.com/tx/)
- Decimals: 8
- Automatic Withdrawal: 0.0001 (Amount that is auto approved for withdrawal without admin consent)

### Adding BEP20

Goto Contract address on [bscscan.com](https://bscscan.com/token/0xe9e7cea3dedca5984780bafc599bd69add087d56) to get details first [Example for BUSD]

### Symbol: busd
- Title: Binance-Peg BUSD Token
- CoinType: Esmart
- Token of: BNB
- RPC Type: Light
- Public RPC URL: [https://bsc-dataseed.binance.org/](https://bsc-dataseed.binance.org/)
- Wallet Server IP: WALLETSERVERIP
- Wallet Server Port: WALLETSERVERPORT
- Server Username: 0xe9e7cea3dedca5984780bafc599bd69add087d56 (get from bscscan.com)
- Wallet Server Password: [of MAIN ACCOUNT]: MAINACCOUNTPWD
- Main Account: MAINACCOUNTADDRESS
- Block Explorer: [https://bscscan.com/tx/](https://bscscan.com/tx/)
- Decimals: 18 (get from bscscan.com)
- Automatic Withdrawal: 0.0001 (Amount that is auto approved for withdrawal without admin consent)

## Usage Steps

A. Deposit Detection [We have set cron to check every minute]
- URL: [https://YOURSITEHERE/Coin/esmart_deposit/securecode/CRONKEYHERE/chain/bnb](https://YOURSITEHERE/Coin/esmart_deposit/securecode/CRONKEYHERE/chain/bnb)

About main account: This is the account where all funds would be moved to, and from here only all withdrawals will take place.

B. Moving User Token [BEP20] to Main Account

Note: Only run manually in the browser's Address Bar. Moving any token will cost gas [BNB]. If the user account does not have enough BNB, then it will extract enough BNB from the Main account and send it to the user account. When the above URL is run again in the browser, the user account will have enough gas to move tokens, and tokens will move to the Main account.

- URL: [https://YOURSITEHERE/Coin/esmart_token_to_main/securecode/CRONKEYHERE/coinname/busd](https://YOURSITEHERE/Coin/esmart_token_to_main/securecode/CRONKEYHERE/coinname/busd)

C. Moving BNB to Main Account

Note: Only run manually in the browser's Address Bar. Moving any BNB will cost gas [BNB], so the main account would receive Balance - Gas.

- URL: [https://YOURSITEHERE/Coin/esmart_to_main/securecode/CRONKEYHERE/coin/bnb](https://YOURSITEHERE/Coin/esmart_to_main/securecode/CRONKEYHERE/coin/bnb)

### Importing Main Account into Metamask
- Download your Main account Keystore file from `/home/geth/mainnet/keystore/ UTC` ... address of the main account.
- Follow this tutorial to import the wallet to Metamask [Step 2](https://medium.com/publicaio/how-import-a-wallet-to-your-metamask-account-dcaba25e558d#3ec7)
