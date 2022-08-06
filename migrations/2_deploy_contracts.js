const MyStaking = artifacts.require('MyStaking');

module.exports = (deployer) => {
  deployer.deploy(MyStaking);
};
