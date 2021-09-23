const BN = require('bn.js');

const NFTContract = artifacts.require("./NFT.sol");

const NAME = "Dev NFT";
const SYMBOL = "dNFT";
const COST = "10000000000000000";
const SUPPLY = "100";
//"Long Name", "SYMBOL", 50000000000000000, 50000

module.exports = async (deployer, network, [owner]) => {
    console.log(`Deploying on ${network}...`);
    await deployer.deploy(NFTContract, NAME, SYMBOL, COST, SUPPLY);

    console.log("Deploying contract...");
    const Token = await NFTContract.deployed();
    console.log(`Deployed ${Token.address}`);
};

