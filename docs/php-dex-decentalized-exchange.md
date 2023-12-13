
## Codno Dex Module [PHP DEX SCRIPT](https://codono.com)

### Step 1: Create Ethereum Account

Create a fresh Ethereum account using Metamask and grab its private key.

### Step 2: Add Tokens

Add the tokens you want to sell (ERC20/BEP20) to the Ethereum account address created in Step 1. The system supports selling only one token using this tool.

### Step 3: Add Gas

Add some gas amount to the Ethereum account.

### Step 4: Dex Configuration

Go to `Admin -> Trade -> Dex Config`

### Step 5: Information Filling

- Default Coin: ETH (Select Main Coin for Dex)
- Default Network: Ropsten (Select Network type for Dex)
- Main Address: 0x2f7f81a71f455156fdd9bcb289621a3537e630b9 (Main address of chain generated in Step 1)
- Private Key: Private Key for Main address generated in Step 1 (Not shown for security)
- Token Name: Token which you sent to main address (Example: MY ABC Token)
- Token Symbol: abc (Symbol of token, lowercase)
- Token Decimals: Decimals on token (example: 8)
- Contract Address: Contract address of token to be sold (example: 0x5fa128ea1eebb38895cc2d5246888f6b062f30b6)
- Token Minimum: Minimum token to be sold in each buy (example: 1.00000000)
- Token Maximum: Maximum Amount of token user can buy (example: 100000.00000000)

### Step 6: Create Coin and Token

Go to `Admin -> Trade -> Dex -> Dex Coins` to add or edit a coin/token.

- Status: Enabled (Coin status)
- Is Default In Spend: NA (Select only one coin as default status, either ETH or BNB)
- Is Token?: Token (Only One main coin)
- Name Of Coin: DAI (Name of coin)
- Symbol Of Coin: dai (Symbol in small letters, e.g., usdt)
- Image: Click Add Picture (80px*80px)
- Contract Address: 0xad6d458402f60fd3bd25163575031acdce07538d (Contract Address of token, Empty in case of main coin)
- Decimals: 18 (Only One main coin)
- Price: 0.01010000 (Price of your token)
- Min Buy Quantity: 0.01000000 (Minimum Buy Quantity)
- Max Buy Quantity: 10000.00000000

### Optional Cron for Missing Deposit Detection

This cron will detect deposits:
```
yoursite/Dex/cronCoinDeposits/securecode/cronkey

```

### Optional Cron for Missing ERC20/BEP20 Deposit Detection

This cron will detect ERC20/BEP20 deposits:
```
yoursite/Dex/cronTokenDeposits/securecode/cronkey

```


### Optional Cron for Handling Abandoned Deposits

This cron sends purchases which were made but didn't get tokens back, sending them tokens for the buy:
```
yoursite.com/Dex/abandonedDeposits/securecode/cronkey

```

