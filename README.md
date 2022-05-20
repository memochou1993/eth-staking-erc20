eth-staking
===

## Quick Start

Try smart contracts with [Remix](https://remix.ethereum.org/) IDE, or follow the steps below to build a local development environment.

1. Install and run [Ganache](https://trufflesuite.com/ganache/).

2. Install [Truffle CLI](https://www.npmjs.com/package/truffle).

3. Install [MetaMask](https://chrome.google.com/webstore/detail/metamask/nkbihfbeogaeaoehlefnkodbefgpgknn)

4. Open MetaMask and add a network:

- Network Name: `localhost 7545`
- RPC Url: `http://localhost:7545`
- Chain ID: `1337`
- Symbol: `ETH`

5. Copy a private key from Ganache, and import to MetaMask.

Install dependencies.

```BASH
npm i
```

Compile and deploy contracts.

```BASH
truffle migrate --reset
```

Interact with contracts.

```BASH
truffle console
```

Run demo page.

```BASH
npm run dev
```
