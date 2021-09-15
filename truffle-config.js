
const HDWalletProvider = require("@truffle/hdwallet-provider");
const infuraRopsten = `https://rinkeby.infura.io/v3/${process.env.INFURA_ID}`;
const infuraMainnet = `https://mainnet.infura.io/v3/${process.env.INFURA_ID}`;

const PRIVATE_KEY = process.env.PRIVATE_KEY;
const ETHERSCAN_KEY = process.env.ETHERSCAN_API_KEY;

module.exports = {
  /**
   * Networks define how you connect to your ethereum client and let you set the
   * defaults web3 uses to send transactions. If you don't specify one truffle
   * will spin up a development blockchain for you on port 9545 when you
   * run `develop` or `test`. You can ask a truffle command to use a specific
   * network from the command line, e.g
   *
   * $ truffle test --network <network-name>
   */
  networks: {
    rinkeby: {
      provider: () => new HDWalletProvider(PRIVATE_KEY, infuraRopsten),
      gasPrice: 50000000000, // 50 gwei,
      network_id: 4,
    },
    mainnet: {
      provider: () => new HDWalletProvider(PRIVATE_KEY, infuraMainnet),
      gasPrice: 40000000000, // 40 gwei
      network_id: 1,
      skipDryRun: true
    }
  },
  // Configure your compilers
  compilers: {
    solc: {
      version: "0.8.4",    // Fetch exact version from solc-bin (default: truffle's version)
    }
  },
  // Truffle DB is currently disabled by default; to enable it, change enabled: false to enabled: true
  db: {
    enabled: false
  },
  //plugin to verify token ownership for etherscan account
  plugins: [
    'truffle-plugin-verify'
  ],
  //used to verify token ownership for etherscan account
  api_keys: {
    etherscan: ETHERSCAN_KEY
  }
};
