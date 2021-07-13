# Setup and Deployment

## Install dependencies
``` npm install ```

## Deploy to network
Example deploying to ropsten:
```INFURA_ID=xxxx PRIVATE_KEY=xxxx BASE_URL="https://localhost:3000" ./node_modules/.bin/truffle migrate --network ropsten ```
- replace `INFURA_ID` value with infura project id.
- replace `PRIVATE_KEY` value with signing private key.
- replace `BASE_URL` value with contact metadata base url.
- replace `--network` value with mainnet when deploying to mainnet.

