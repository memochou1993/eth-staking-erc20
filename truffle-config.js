const HDWalletProvider = require('@truffle/hdwallet-provider');
require('dotenv').config();

const { PROVIDER_URL, PRIVATE_KEY, ETHERSCAN_API_KEY } = process.env;

module.exports = {
  networks: {
    development: {
      host: '127.0.0.1',
      port: 7545,
      network_id: '*',
    },
    goerli: {
      provider: () => new HDWalletProvider(PRIVATE_KEY, PROVIDER_URL),
      network_id: '5',
      skipDryRun: true,
    },
  },
  compilers: {
    solc: {
      version: '0.8.13',
      settings: {
        optimizer: {
          enabled: true,
          runs: 200,
        },
      },
    },
  },
  plugins: [
    'truffle-plugin-verify',
    'solidity-coverage',
  ],
  api_keys: {
    etherscan: ETHERSCAN_API_KEY,
  },
};
