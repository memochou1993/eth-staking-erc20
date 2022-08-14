const ERC20Mock = artifacts.require('ERC20Mock');
const Staking = artifacts.require('Staking');

module.exports = async (deployer, network) => {
  switch (network) {
    case 'mainnet':
      //
      break;
    default:
      await deployer.deploy(ERC20Mock);
      await deployer.deploy(Staking, (await ERC20Mock.deployed()).address);
      break;
  }
};
