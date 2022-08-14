# eth-staking-erc20

This project provides a staking application.

## Requirements

- Node.js 16.15.1 (LTS)
- An Alchemy account for deploying the contract.
- An Etherscan account for verifying the contract.

## Development

Clone the repository and install dependencies.

```BASH
npm ci
```

Copy `.env.example` to `.env`.

Follow the steps below to set up a local development environment.

1. Install and run [Ganache](https://trufflesuite.com/ganache/).

2. Install [MetaMask](https://chrome.google.com/webstore/detail/metamask/nkbihfbeogaeaoehlefnkodbefgpgknn).

3. Copy a private key from Ganache, and import to MetaMask.

4. Add a network to MetaMask.

- Network Name: `Localhost 7545`
- RPC URL: `http://localhost:7545`
- Chain ID: `1337`
- Symbol: `ETH`

Compile and deploy contracts.

```BASH
npm run migrate -- --reset
```

Add contract addresses to `.env` file.

```ENV
VITE_ERC20MOCK_ADDRESS=0x...
VITE_STAKING_ADDRESS=0x...
```

Run demo page.

```BASH
npm run dev
```

Switch network to `Localhost 7545` on MetaMask.

## Testing

Run test cases.

```BASH
npm run test
```

## Deployment

### Goerli Testnet

Update `.env` file.

```ENV
PROVIDER_URL=https://eth-goerli.alchemyapi.io/v2/your-api-key
PRIVATE_KEY=your-private-key
ETHERSCAN_API_KEY=your-etherscan-api-key
```

Request free Goerli ETH from [Goerli Faucet](https://goerlifaucet.com/).

Compile and deploy contracts.

```BASH
npm run migrate -- --network goerli
```

Verify contracts.

```BASH
npm run verify -- Staking --network goerli
```

Add contract addresses to `.env` file.

```ENV
VITE_ERC20MOCK_ADDRESS=0x...
VITE_STAKING_ADDRESS=0x...
```

Run demo page.

```BASH
npm run dev
```

Switch network to `Goerli Testnet` on MetaMask.
