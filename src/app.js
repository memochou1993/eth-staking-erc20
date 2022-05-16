class App {
  constructor() {
    if (!window.ethereum) {
      console.log('Please connect to Metamask.');
      return;
    }
    window.ethereum.on('accountsChanged', () => this.init());
    this.init();
  }

  async init() {
    await this.loadAccount();
    await this.loadContract();
    await this.loadDecimals();
    if (this.account) {
      await this.render();
    }
  }

  async loadAccount() {
    const [account] = await window.ethereum.request({ method: 'eth_requestAccounts' });
    this.account = account;
  }

  async loadContract() {
    const contract = TruffleContract(await fetch('Staking.json').then((r) => r.json()));
    contract.setProvider(await detectEthereumProvider());
    this.contract = await contract.deployed();
  }

  async loadDecimals() {
    this.decimals = (await this.contract.decimals()).toNumber();
  }

  async render() {
    document.getElementById('account').textContent = this.account;
    document.getElementById('balanceOf').textContent = this.formatNumber((await this.contract.balanceOf(this.account)).toNumber());
    document.getElementById('isStakeholder').textContent = (await this.contract.isStakeholder(this.account))[0];
  }

  async createStake() {
    const amount = Number(document.getElementById('stakeAmount').value) * (10 ** this.decimals);
    await this.contract.createStake(amount, this.payload());
    window.location.reload();
  }

  async transfer() {
    const to = document.getElementById('to').value;
    const amount = Number(document.getElementById('transferAmount').value) * (10 ** this.decimals);
    await this.contract.transfer(to, amount, this.payload());
    window.location.reload();
  }

  formatNumber(number) {
    return (number / (10 ** this.decimals)).toFixed(this.decimals);
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
