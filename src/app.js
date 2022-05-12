class App {
  constructor() {
    if (!window.ethereum) {
      console.log('Please connect to Metamask.');
      return;
    }
    window.ethereum.enable();
    window.ethereum.on('accountsChanged', () => this.init());
    this.web3 = new Web3(window.ethereum);
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
    this.stake = (await this.contract.stakeOf(this.account));
    document.getElementById('account').textContent = this.account;
    document.getElementById('balanceOf').textContent = (await this.contract.balanceOf(this.account)).toNumber();
    document.getElementById('amount').textContent = this.stake.amount;
    document.getElementById('earned').textContent = this.stake.earned;
    document.getElementById('rewardRate').textContent = this.stake.rewardRate;
    document.getElementById('createdAt').textContent = this.stake.createdAt;
    document.getElementById('isStakeholder').textContent = (await this.contract.isStakeholder(this.account))[0];
    document.getElementById('totalStakeAmount').textContent = await this.contract.totalStakeAmount();
    document.getElementById('totalSupply').textContent = await this.contract.totalSupply();
    setInterval(() => {
      if (Number(this.stake.createdAt) === 0) {
        return;
      }
      const rewardPerSecond = Math.floor((this.stake.amount * this.stake.rewardRate) / 100 / 365 / 86400);
      const estimatedReward = (Math.floor(+new Date() / 1000) - this.stake.createdAt) * rewardPerSecond - this.stake.earned;
      document.getElementById('estimatedReward').textContent = estimatedReward;
    }, 1000);
  }

  async createStake() {
    const amount = document.getElementById('stakeAmount').value;
    await this.contract.createStake(amount, this.payload());
    window.location.reload();
  }

  async removeStake() {
    await this.contract.removeStake(this.payload());
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
