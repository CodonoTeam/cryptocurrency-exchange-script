## CryptoApis Integration Setup

### Step 1: Create API Key

1. Login to [https://my.cryptoapis.io/](https://my.cryptoapis.io/)
2. Create a new API Key.
3. Enable the API Key and give all route permissions.
4. Save the `api_key` in Notepad.

### Step 2: Create New Wallet

1. Go to the Dashboard of CryptoApis.
2. Go to My Wallet -> New Mainnet Wallet.
3. Save the `WalletId` in Notepad.

### Step 3: Create Ethereum Account (Only for Ethereum)

1. Go to the Dashboard of CryptoApis.
2. Go to My Wallet -> Addresses -> New Deposit Address.
3. Label: `mainAccount`, Blockchain Protocol: Ethereum, Network: Mainnet.
4. Save the generated Address to notepad.

### Adding Ethereum

Symbol: eth
- Title: Ethereum
- CoinType: CryptoApis
- Token of: none
- Network: mainnet
- Walletid: WalletID saved in Step 2
- Contract Address: Leave Blank
- API Key: Api_key saved in Step 1
- Main Account: mainAccount saved in Step 3
- Block Explorer: [https://etherscan.io/tx/](https://etherscan.io/tx/)
- Decimals: 8

### Adding Bitcoin

Symbol: btc
- Title: Bitcoin
- CoinType: CryptoApis
- Network Type: mainnet
- Walletid: WalletID saved in Step 2
- Contract Address: Leave Blank
- API Key: Api_key saved in Step 1
- Main Account: Leave Blank
- Block Explorer: [https://www.blockchain.com/btc/tx/](https://www.blockchain.com/btc/tx/)
- Decimals: 8

### IPN Generated URL

Your website must run on HTTPS (SSL) to support callback.
- IPN URL: [https://yoursite.com/IPN/callback_cryptoapis](https://yoursite.com/IPN/callback_cryptoapis)

### Cron URL

Run every 10 minutes max to manage API requests.
- Cron URL: [https://yoursite.com/Coin/deposit_cryptoapis/securecode/cronkey](https://yoursite.com/Coin/deposit_cryptoapis/securecode/cronkey)

### Step 6: Create Coin and Token

In Step 5, you selected the default coin and its network. Now, you can create a coin and token on the same network to sell it against the token.

Go to Admin -> Trade -> Dex -> Dex Coins, and then Add or Edit the coin details:

- Status: Enabled [Coin status]
- Is Default In Spend: NA [Select only one coin as default status either ETH or BNB]
- Is Token?: Token [Only One main coin]
- Name Of Coin: DAI [Name of coin]
- Symbol Of Coin: dai [symbol in small letters, e.g., usdt]
- Image: Click Add Picture 80px*80px
- Contract Address: 0xad6d458402f60fd3bd25163575031acdce07538d [Contract Address of token, Empty in case of the main coin]
- Decimals: 18 [Only One main coin]
- Price: 0.01010000 [Price of your token]
- Min Buy Quantity: 0.01000000 [Minimum Buy Quantity]
- Max Buy Quantity: 10000.00000000

### Note
Replace placeholders like WALLETSERVERIP, WALLETSERVERPORT, MAINACCOUNTPWD, MAINACCOUNTADDRESS, YOURSITEHERE, and CRONKEYHERE with the actual values as needed.
