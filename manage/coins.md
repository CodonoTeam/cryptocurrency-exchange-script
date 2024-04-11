# Adding a New Coin to Codono Exchange

## Overview

This guide explains how to add a new cryptocurrency to your Codono exchange platform. The "Add Coin" form allows for the integration of various coin types, including native cryptocurrencies and tokens from different blockchain networks such as TRC20, and Blockgum EVM Wallets[ERC20, BEP20, FTM20, EVM20 etc]. 

Refer to our specific tutorials for [TRC20](https://github.com/CodonoTeam/cryptocurrency-exchange-script/blob/main/docs/trc20-setup.md), and [Blockgum setup](https://github.com/CodonoTeam/cryptocurrency-exchange-script/blob/main/docs/blockgum-integration.md) for detailed steps on configuring each coin type.

## Form Fields and Instructions

### Basic Information

- **Unique Symbol**: Enter the abbreviated symbol of the coin. Only use 3-6 lowercase alphabetical characters.
- **Parent Symbol**: For tokens belonging to a parent chain, enter the symbol of the primary cryptocurrency (e.g., `bnb` for BEP20 tokens).
- **Frontend Title**: The name displayed on the frontend (e.g., Bitcoin Cash).

### Coin Properties

- **Coin Type**: Select the category that best describes your coin. This could be an ICO coin, a fiat coin, or associated with a particular blockchain network.
- **Token Type**: Specify if your asset is a token and its standard, such as ERC20 or BEP20.

### Network Settings

- **Public RPC URL**: Input the public RPC URL if required by the coin type for blockchain interactions.

### Wallet Configuration

(These fields are typically not required for ICO coins)

- **Wallet Server IP/Port/Username/Password**: Provide the connection details to the wallet server if applicable.
- **Main Address**: For offline coins or main wallets handling multiple user transactions.

### Trading Parameters

- **Block Explorer**: URL to a block explorer supporting the coin for transaction verification.
- **Decimal Places**: Number of decimal places that the coin can be divided into.

### Fee Structure

- **List Ratio**: The percentage fee applied to coin listings.
- **Deposits**: Toggle to enable or disable deposits.
- **Network Confirmations**: The number of confirmations needed for network validation.

### Withdrawal Controls

- **Fees Coin**: The currency used for withdrawal fees.
- **Withdrawal Fee % / Flat Fee**: Define the percentage or flat rate for withdrawal fees.
- **Fee Userid**: User ID that receives the fees.
- **Min/Max Withdrawal Amount**: Set thresholds for withdrawal amounts.
- **Withdrawal Status**: Enable or disable withdrawals.

### Detailed Information

- **Details**: Additional information about the coin.
- **Download Wallet**: Where users can download the coin's wallet.
- **Source Download**: Location of the coin's source code.
- **Official Link / Forums**: Official resources for user reference.
- **Developers**: Names or teams of developers.
- **Core Algorithm**: The coin's underlying algorithm.

### Technical Specifications

- **Release Date**: Launch date of the coin.
- **Proof Method**: Consensus mechanism used.
- **Total Issued**: The total number of coins issued.
- **Stock**: How much is currently in circulation.
- **Difficulty Adjustment**: Details on how the coin adjusts its mining difficulty.
- **Block Award**: Block mining reward.
- **Key Features**: Notable functionalities.
- **Shortcomings**: Any current limitations or issues.

After filling out all the necessary fields, click "Submit" to add the coin to the exchange.
For step-by-step instructions on configuring each type of coin, refer to the respective documentation within the `docs` directory of this repository.

