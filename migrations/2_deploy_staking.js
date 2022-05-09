const Staking = artifacts.require('Staking');

module.exports = (deployer) => {
  deployer.deploy(Staking);
};
