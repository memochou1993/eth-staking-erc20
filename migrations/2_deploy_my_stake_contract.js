const MyStake = artifacts.require('MyStake');

module.exports = (deployer) => {
  deployer.deploy(MyStake);
};
