# Liquidity Bot in the Codono Script

In the Codono script, the "Liquidity Bot" refers to a software component designed to provide liquidity in cryptocurrency trading. Liquidity refers to the ease with which an asset can be bought or sold without significantly affecting its price. The Liquidity Bot's primary goal is to ensure there is enough supply and demand for a particular cryptocurrency trading pair, minimizing slippage and enhancing trading efficiency.

## How the Liquidity Bot Works

- **Order Book Monitoring:** The Liquidity Bot constantly monitors the order books of various market pairs.

- **Orderbook Creation:** Periodically, the Liquidity Bot identifies trading pairs and automatically places both buy and sell orders at prices close to the current market price. These orders are usually smaller than typical market orders and have a markup commission set in the admin area.

- **Market Maker Strategy:** The bot follows a market maker strategy. It aims to profit from the spread between buy and sell orders. By placing buy orders slightly below the market price and sell orders slightly above the market price, the bot provides liquidity to traders who wish to execute trades quickly.

- **Order Adjustment:** As the market price fluctuates, the Liquidity Bot adjusts its orders to maintain a competitive spread and adapt to changing market conditions.

- **Risk Management:** The bot includes risk management mechanisms to prevent large losses. For instance, it may set maximum order sizes.

- **Cross Trading:** The bot may also cross trade and match on Binance Exchange for the same orders that got executed on your exchange.

By providing liquidity, the Liquidity Bot helps create a more efficient trading environment, attracting more traders and investors to the platform. This, in turn, can enhance the overall trading experience and potentially increase trading volumes on the Codono platform.


# Bot Setup on Codono System

## Step 1: Configure 2 Spot API Keys in `other_config.php`

Open the `other_config.php` file in a text editor.

Configure two Spot API keys in the file as follows:

```php
// Replace 'your_api_key1' and 'your_api_secret1' with your first API key credentials
define('API_KEY_1', 'your_api_key1');
define('API_SECRET_1', 'your_api_secret1');

// Replace 'your_api_key2' and 'your_api_secret2' with your second API key credentials
define('API_KEY_2', 'your_api_key2');
define('API_SECRET_2', 'your_api_secret2');
```

Ensure that you obtain these API keys from your Binance account or exchange and keep them secure. These keys will be used for trading and accessing your Binance account.

## Step 2: Update Market Settings in Admin Panel

1. Log in to your Codono admin panel.
2. Navigate to `Admin -> Trade -> Market -> Edit`.
3. Configure the following settings:

   - **Liquidity**: Switch it to "Binance Engine".
   - **External Orderbook Markup**: Set it to a value between 0.1% to 10% (or any profitable percentage) based on your preferences.
   - **Cross Ordering From Binance**: Enable this option.

4. After making the changes, remember to clear the cache from the admin panel. You can usually find the option to clear the cache in the top right menu of the admin panel.

## Step 3: Set Up the Cron Job

Make sure to run the following cron job every minute:

```
http://codono.local/Xtrade/cronMe/securecode/cronkey/
```

Replace `codono.local` with your actual website URL or server IP address, and `cronkey` with the cron key you have set up in your system.

For example, if your Codono site is running on `http://exchange.mydomain.com/` and your cron key is `mycronkey123`, the cron job URL would be:

```
http://exchange.mydomain.com/Xtrade/cronMe/securecode/mycronkey123/
```

This cron job is essential for maintaining the proper functioning of the exchange and should be executed at regular intervals (ideally every minute) to keep the market data up-to-date and execute trades efficiently. Ensure that the cron job runs successfully without any errors.
