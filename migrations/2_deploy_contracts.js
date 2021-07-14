const BN = require('bn.js');

const NFTContract = artifacts.require("./NFT.sol");

const NAME = "TestNFT";
const SYMBOL = "tNFT";
const COST = "10000000000000000";
const SUPPLY = "5";
//const BASE_URL = process.env.BASE_URL;

module.exports = async (deployer, network, [owner]) => {
    console.log(`Deploying on ${network}...`);
    await deployer.deploy(NFTContract, NAME, SYMBOL, COST, SUPPLY);

    console.log("Deploying contract...");
    const Token = await NFTContract.deployed();
    console.log(`Deployed ${Token.address}`);
};