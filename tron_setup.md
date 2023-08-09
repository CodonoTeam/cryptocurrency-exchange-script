## Tron Code in Codono Ultra

Tron Code is built into Codono Ultra and does not require any additional Coin node.

### Setup Instructions

#### Generating Main Tron Account

You can generate the Main Tron account externally or by running the following URL:

```
yoursite.com/Tron/makeOneAccount/securecode/cronkey

```

It will provide you with the following information. Save this information securely if you plan to use this account as the Main account:

```
Array
(
[private_key] => 6c25cc8ba4da6f75************************
[public_key] => 0442281c4a2fb2e58f57bbb42f8d2b0ac00252aee341fdae45f05748d4fc2e2e83e8bb8e872da8157b7258cd09aa0c35d404d568bce1430398ef7e88eb6e6674b8
[address_hex] => 41f8cbbde4e0433333f2ea1bbedf0647447a5fa9f8
[address_base58] => TYeieronBA8hbbUpW7fekUqjdUQdmR78oX
)
```


Please note that this information will vanish on refresh, as it is not saved anywhere. If you plan to use this account as the Main account, save this information somewhere safe, print it, and keep it secure.

Now go to `Admin -> Coin -> Find trx` or add a new one if it doesn't exist.

- Symbol: trx
- Parent Symbol: trx
- Frontend Title: Tron [Trc20]
- Coin Type: Tron Network [Trc20]
- Token of: none
- Wallet Server IP: [Keep Empty]
- Wallet Server Port: [Keep Empty]
- Server Username: [Keep Empty]
- Wallet Server Password: [private_key generated from above step]
- Main Account: [address_base58 value from above step]
- Block Explorer: [Tronscan Transaction Explorer](https://tronscan.org/#/transaction/)
- Decimal: 6

#### Adding TRC20 Tokens

For example, let's add USDT: [Tronscan USDT Token](https://tronscan.io/#/token20/TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t)

- Symbol: tusdt [unique key for symbol]
- Parent Symbol: usdt [main coin symbol]
- Frontend Title: USDT [Trc20]
- Coin Type: Tron Network [Trc20]
- Token of: trx
- Wallet Server IP: [Keep Empty]
- Wallet Server Port: [Keep Empty]
- Server Username: TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t [contract address]
- Wallet Server Password: [private_key generated from above step]
- Main Account: [address_base58 value from above step]
- Block Explorer: [Tronscan Transaction Explorer](https://tronscan.org/#/transaction/)
- Decimal: 6

#### Deposit Cron: Run Every Minute

```
yoursite.com/Tron/cronDeposits/securecode/cronkey

```

#### Moving Token to Main Account (Example: USDT)

```
yoursite.com/Tron/moveTokenToMain/securecode/cronkey/token/usdt

```


#### Moving Tron to Main Account (Example: USDT)

```
yoursite.com/Tron/moveTronToMain/securecode/cronkey/

```



#### Saving ABI File (For Each Token)

1. Go to the token code page on Tronscan, e.g. [Tronscan Token Code](https://tronscan.io/#/token20/TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t/code)
2. Copy the Contract ABI
3. Save it in the following location: `Public/ABI`

Example file names (capitalized):

- USDT.abi
- UNI.abi

