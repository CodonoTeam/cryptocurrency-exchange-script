# Welcome to Substrate Solution by Codono.com!

Substrate repository contains two sub-folders. Block listener and Wallet Engine.

Block Listener is responsible for checking new blocks on the respective blockchain and adding it to the mongoDB database.

Wallet Engine is responsible for making transactions.

# Local Setup

Simply clone the repository using **git clone** or download the code as zip.

There is an **env.example** file in root directory. Copy and rename it to **.env**. And change the values accordingly.

Perform **npm install** in both sub-folders.

If you are facing some errors while executing **npm install**, try changing npm version to the **16.10.0** using **nvm**.

### Starting Block Listener & MongoDB & Wallet Engine

First make sure you have **yarn** and **nvm** installed on your system.

Run **pm2 start** in root directory.

If you are facing errors with any process. You can start them manually.

Manual commands are for:
## First run for NPM installation , and Building package
Must run and it should build following directories ./wallet-engine/node_modules ,./block-listener/node_modules ,./block-listener/build
**npm run start-init**

### Starting MongoDB Manually

**npm run start-mongodb**

### Starting Block Listener Manually

**npm run start-block**

### Starting Wallet Engine

**npm run start-wallet**

Note: If you still facing error while starting Wallet engine. Try using Node version **16.10.0** using **nvm** and re-execute the above command.

# Encrypting and Decrypting values

You will have to encrypt values such as **xprv**. In the root directory, execute **npm run encrypt example_value**.

Note: Replace **example_value** with your real value.

For example: **npm run encrypt E502xi0Q87HE502xi0Q87HE502xi0Q87H**

# Transactions are getting failed

If transfers are getting failed then make sure the account, to which payment is being made to, must have at least **0.1 WND** to be **eligible** to receive payments.

# Ports

**MongoDB service** uses port **22546** & **Wallet Engine** uses port **22547**.
