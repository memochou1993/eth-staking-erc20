class App {
  constructor() {
    if (!window.ethereum) {
      console.log('Please connect to Metamask.');
      return;
    }
    this.web3 = new Web3(window.ethereum);
    window.ethereum.enable();
    this.init();
  }

  async init() {
    await this.loadAccount();
    await this.loadContract();
    await this.render();
  }

  async loadAccount() {
    const [account] = await this.web3.eth.getAccounts();
    this.account = account;
  }

  async loadContract() {
    const contract = TruffleContract(await fetch('Staking.json').then((r) => r.json()));
    contract.setProvider(web3.currentProvider);
    this.contract = await contract.deployed();
  }

  async render() {
    document.getElementById('account').textContent = this.account;
    document.getElementById('isStakeholder').textContent = (await this.contract.isStakeholder(this.account))[0];
    document.getElementById('stakeOf').textContent = (await this.contract.stakeOf(this.account)).toNumber();
    document.getElementById('rewardOf').textContent = (await this.contract.rewardOf(this.account)).toNumber();
    document.getElementById('balanceOf').textContent = (await this.contract.balanceOf(this.account)).toNumber();
    document.getElementById('totalStakes').textContent = await this.contract.totalStakes();
    document.getElementById('totalRewards').textContent = await this.contract.totalRewards();
    document.getElementById('totalSupply').textContent = await this.contract.totalSupply();
  }

  async createStake() {
    const amount = document.getElementById('stakeAmount').value;
    await this.contract.createStake(amount, this.payload());
    window.location.reload();
  }

  async removeStake() {
    const amount = document.getElementById('stakeAmount').value;
    await this.contract.removeStake(amount, this.payload());
    window.location.reload();
  }

  async withdrawReward() {
    await this.contract.withdrawReward(this.payload());
    window.location.reload();
  }

  async distributeRewards() {
    await this.contract.distributeRewards(this.payload());
    window.location.reload();
  }

  async transfer() {
    const to = document.getElementById('to').value;
    const amount = document.getElementById('transferAmount').value;
    await this.contract.transfer(to, amount, this.payload());
    window.location.reload();
  }

  payload() {
    return {
      from: this.account,
      gas: 300000,
      gasPrice: 1500000000,
    };
  }
}

const app = new App();
