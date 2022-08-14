import Vue from 'vue/dist/vue';
import { ethers } from 'ethers';
import ERC20Mock from '../build/contracts/ERC20Mock.json';
import Staking from '../build/contracts/Staking.json';
import './style.css';

new Vue({
  el: '#app',
  data: () => ({
    web3Provider: null,
    account: null,
    /**
     * ERC20Mock contract data
     */
    decimals: null,
    allowance: null,
    balanceOf: null,
    /**
     * Staking contract data
     */
    rewardRateDecimals: null,
    isStakeholder: null,
    totalStaked: null,
    rewardPool: null,
    rewardPlans: null,
    stakes: null,
    /**
     * form data
     */
    stakeAmount: '',
    rewardPlanIndex: '',
    rewardPlanName: '',
    rewardPlanDuration: '',
    rewardPlanRate: '',
    rewardAmount: '',
    rewardPlanIndexForUpdate: '',
    rewardPlanNameForUpdate: '',
  }),
  computed: {
    signer() {
      return this.web3Provider.getSigner();
    },
    ERC20Mock() {
      return new ethers.Contract(import.meta.env.VITE_ERC20MOCK_ADDRESS, ERC20Mock.abi, this.signer);
    },
    Staking() {
      return new ethers.Contract(import.meta.env.VITE_STAKING_ADDRESS, Staking.abi, this.signer);
    },
  },
  created() {
    if (!window.ethereum) {
      console.log('Please connect to Metamask.');
      return;
    }
    this.init();
  },
  methods: {
    async init() {
      await this.loadWeb3Provider();
      await this.loadAccount();
      await this.loadData();
    },
    async loadWeb3Provider() {
      this.web3Provider = new ethers.providers.Web3Provider(window.ethereum, 'any');
      this.web3Provider.provider.on('accountsChanged', () => this.init());
    },
    async loadAccount() {
      const [account] = await this.web3Provider.send('eth_requestAccounts');
      this.account = account;
    },
    async loadData() {
      if (!this.account) {
        return;
      }
      this.decimals = await this.ERC20Mock.decimals(); // use number
      this.allowance = await this.ERC20Mock.allowance(this.account, this.Staking.address); // use BigNumber
      this.balanceOf = await this.ERC20Mock.balanceOf(this.account);
      this.rewardRateDecimals = await this.Staking.rewardRateDecimals(); // use number
      this.isStakeholder = await this.Staking.isStakeholder(this.account);
      this.totalStaked = await this.Staking.totalStaked();
      this.rewardPool = await this.Staking.rewardPool();
      this.rewardPlans = await this.Staking.getRewardPlans();
      this.stakes = (await this.Staking.stakesOf(this.account)).filter((stake) => stake.amount.gt(0));
    },
    async approve() {
      const amount = ethers.BigNumber.from(2).pow(256).sub(1); // use BigNumber
      const res = await this.ERC20Mock.approve(this.Staking.address, amount);
      await res.wait();
      window.location.reload();
    },
    async addReward() {
      const amount = ethers.BigNumber.from(1).mul(ethers.FixedNumber.fromString(this.rewardAmount)); // use BigNumber
      const res = await this.Staking.addReward(amount);
      await res.wait();
      window.location.reload();
    },
    async createStake() {
      const amount = ethers.BigNumber.from(1).mul(ethers.FixedNumber.fromString(this.stakeAmount)); // use BigNumber
      const res = await this.Staking.createStake(amount, this.rewardPlanIndex);
      await res.wait();
      window.location.reload();
    },
    async removeStake(index) {
      const res = await this.Staking.removeStake(index);
      await res.wait();
      window.location.reload();
    },
    async createRewardPlan() {
      const rewardPlanRate = (Number(this.rewardPlanRate) * 10 ** this.rewardRateDecimals) / 100;
      const res = await this.Staking.createRewardPlan(this.rewardPlanName, this.rewardPlanDuration, rewardPlanRate);
      await res.wait();
      window.location.reload();
    },
    async updateRewardPlan() {
      const res = await this.Staking.updateRewardPlan(this.rewardPlanIndexForUpdate, this.rewardPlanNameForUpdate);
      await res.wait();
      window.location.reload();
    },
    async removeRewardPlan(index) {
      const res = await this.Staking.removeRewardPlan(index);
      await res.wait();
      window.location.reload();
    },
    rewardPlanOf(stake) {
      return this.rewardPlans?.find((rewardPlan) => rewardPlan.index.toNumber() === stake.rewardPlanIndex.toNumber());
    },
    isUnlockable(stake) {
      const rewardPlan = this.rewardPlanOf(stake);
      return Math.floor(+new Date() / 1000) - stake.createdAt > rewardPlan.duration;
    },
    estimatedReward(stake) {
      const rewardPlan = this.rewardPlanOf(stake);
      const duration = Math.floor(+new Date() / 1000) - stake.createdAt;
      const reward = (((duration * stake.amount * rewardPlan.rate) / (10 ** this.rewardRateDecimals)) / 365) / 86400;
      const total = this.estimatedTotalReward(stake);
      return reward > total ? total : reward;
    },
    estimatedTotalReward(stake) {
      const rewardPlan = this.rewardPlanOf(stake);
      return (((rewardPlan.duration * stake.amount * rewardPlan.rate) / (10 ** this.rewardRateDecimals)) / 365) / 86400;
    },
    formatNumber(number = 0) {
      return Number(number / (10 ** this.decimals)).toFixed(2);
    },
    formatRewardRateNumber(number = 0) {
      return Number((number / (10 ** this.rewardRateDecimals)) * 100).toFixed(2);
    },
  },
});

Vue.component('TextUpdater', {
  name: 'TextUpdater',
  props: {
    text: {
      type: Function,
      default: () => {},
    },
  },
  data: () => ({
    display: '',
  }),
  created() {
    setInterval(() => {
      this.display = this.text();
    }, 1000);
  },
  template: '<span>{{ display }}</span>',
});

window.onload = () => document.body.removeAttribute('hidden');
