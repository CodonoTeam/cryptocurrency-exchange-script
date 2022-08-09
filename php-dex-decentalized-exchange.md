#Codno Dex Module [PHP DEX SCRIPT](https://codono.com)
You must have following 


Step 1. Create a fresh ethereum account using metamask and grab its Private key
Step 2. Add some Tokens that you want to sell [ ERC20/BEP20] to above  ethereum account address , System support only one token sell using this tool.
Step 3. Add some Gas amount to ethereum account
Step 4. Goto -> Admin -> Trade-> Dex Config 
Step 5. Information Filling
```
Default Coin:	ETH [Select Main Coin For Dex ]
Default Network:	 Ropsten [Select Network type For Dex]
Main Address :	0x2f7f81a71f455156fdd9bcb289621a3537e630b9 [Main address of chain that you generated in step1 ]
Private Key :	Private Key for Main address geenrated in step 1 [Not shown for security]
Token Name :	Token which you sent to main address  Example MY ABC Token
Token Symbol :	abc [Symbol of token ,small letters]
Token Decimals : Decimals on token  example 8 [Do not fill wrong ]
Contract Address :Contract address of token to be sold 	example 0x5fa128ea1eebb38895cc2d5246888f6b062f30b6
Token Minimum :	 Minimum token to be sold in each buy [example 1.00000000]
Token Maximum :	Maximum Amount of token user can buy [example 100000.00000000]
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

Optional Cron for missing Deposit detection ,  This cron will detect deposits .
```
yoursite/Dex/cronCoinDeposits/securecode/cronkey
```


Optional Cron for missing Deposit erc20 /bep20 detection ,  This cron will detect deposits .
```
yoursite/Dex/cronTokenDeposits/securecode/cronkey
```

This cron sends purchases which were made but they didnt get token back, send them tokens for the buy.
```
yoursite.com/Dex/abandonedDeposits/securecode/cronkey
```
