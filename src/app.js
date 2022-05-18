new Vue({
  el: '#root',
  data: {
    /**
     * form data
     */
    amount: '',
    rewardPlanIndex: '',
    rewardPlanDuration: '',
    rewardPlanRewardRage: '',
    /**
     * display data
     */
    rewardPlans: [],
    stakes: [],
    account: '',
    balanceOf: '',
    isStakeholder: false,
  },
  created() {
    if (!window.ethereum) {
      console.log('Please connect to Metamask.');
      return;
    }
    window.ethereum.on('accountsChanged', () => this.init());
    this.init();
  },
  methods: {
    async init() {
      await this.loadAccount();
      await this.loadContract();
      await this.loadData();
    },
    async loadAccount() {
      const [account] = await window.ethereum.request({ method: 'eth_requestAccounts' });
      this.account = account;
    },
    async loadContract() {
      const contract = TruffleContract(await fetch('Staking.json').then((r) => r.json()));
      contract.setProvider(await detectEthereumProvider());
      this.contract = await contract.deployed();
    },
    async loadData() {
      if (!this.account) {
        return;
      }
      this.decimals = (await this.contract.decimals()).toNumber();
      this.isStakeholder = await this.contract.isStakeholder(this.account);
      this.balanceOf = this.formatNumber((await this.contract.balanceOf(this.account)).toNumber());
      this.rewardPlans = (await this.contract.getRewardPlans(this.payload()));
      if (this.isStakeholder) {
        this.stakes = (await this.contract.getStakes(this.payload()));
      }
    },
    async deposit() {
      const amount = Number(this.amount) * (10 ** this.decimals);
      await this.contract.deposit(amount, this.rewardPlanIndex, this.payload());
      window.location.reload();
    },
    async withdraw(index) {
      await this.contract.withdraw(index, this.payload());
      window.location.reload();
    },
    async createRewardPlan() {
      await this.contract.createRewardPlan(this.rewardPlanDuration, this.rewardPlanRewardRage, this.payload());
      window.location.reload();
    },
    async removeRewardPlan(index) {
      await this.contract.removeRewardPlan(index, this.payload());
      window.location.reload();
    },
    estimatedReward(stake) {
      const rewardPerSecond = Math.floor((stake.locked * stake.rewardRate) / 100 / 365 / 86400);
      return (Math.floor(+new Date() / 1000) - stake.createdAt) * rewardPerSecond;
    },
    estimatedTotalReward(stake) {
      return Math.floor((((stake.locked * stake.rewardRate) / 100) / 365) * 7);
    },
    formatNumber(number) {
      return (number / (10 ** this.decimals)).toFixed(this.decimals);
    },
    payload() {
      return {
        from: this.account,
        gas: 300000,
        gasPrice: 1500000000,
      };
    },
  },
});

window.onload = () => document.body.removeAttribute('hidden');
