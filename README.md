# Setup and Deployment

## Install dependencies
``` npm install ```

## Deploy to network
Example deploying to ropsten:
```INFURA_ID=xxxx PRIVATE_KEY=xxxx ./node_modules/.bin/truffle migrate --network ropsten ```
- replace `INFURA_ID` value with infura project id.
- replace `PRIVATE_KEY` value with signing private key.
- replace `--network` value with mainnet when deploying to mainnet.

## Verifying on etherscan
Flatten the contracts:
```./node_modules/.bin/poa-solidity-flattener ./contracts/NFT.sol```
Use the file in `/out` directory to verify

