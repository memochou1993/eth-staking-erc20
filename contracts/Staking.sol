// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Staking is ERC20, Ownable {
    using SafeMath for uint256;

    uint256 public constant INITIAL_SUPPLY = 1e10;
    uint256 public duration = 30 seconds; // 7 days
    uint256 public rewardRate = 100;

    struct Stakeholder {
        address addr;
        Stake[] stakes;
    }

    struct RewardPlan {
        uint256 index;
        uint256 duration;
        uint256 rewardRate;
    }

    struct Stake {
        uint256 index;
        uint256 locked;
        uint256 unlocked;
        uint256 duration;
        uint256 rewardRate;
        uint256 rewardClaimed;
        uint256 createdAt;
    }

    Stakeholder[] public stakeholders;
    mapping(address => uint256) public stakeholderIndexes;

    RewardPlan[] public rewardPlans;

    constructor() ERC20("My Token", "MTK") {
        stakeholders.push();
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    modifier onlyStakeholder() {
        require(isStakeholder(msg.sender), "Staking: caller is not the stakeholder");
        _;
    }

    function getRewardPlans()
        external
        view
        returns (RewardPlan[] memory)
    {
        return rewardPlans;
    }

    function getStakes()
        external
        view
        onlyStakeholder
        returns (Stake[] memory)
    {
        uint256 _stakeholderIndex = stakeholderIndexes[msg.sender];
        return stakeholders[_stakeholderIndex].stakes;
    }

    function decimals()
        public
        view
        virtual
        override
        returns (uint8)
    {
        return 2;
    }

    function deposit(uint256 _amount)
        public
    {
        require(_amount > 0, "Staking: amount cannot be zero");
        uint256 _stakeholderIndex = stakeholderIndexes[msg.sender];
        if (!isStakeholder(msg.sender)) {
            _stakeholderIndex = register(msg.sender);
        }
        stakeholders[_stakeholderIndex].stakes.push(Stake({
            index: stakeholders[_stakeholderIndex].stakes.length,
            locked: _amount,
            unlocked: 0,
            duration: duration,
            rewardRate: rewardRate,
            rewardClaimed: 0,
            createdAt: block.timestamp
        }));
        _burn(msg.sender, _amount);
        // TODO: emit StakeCreated
    }

    function withdraw(uint256 _stakeIndex)
        public
        onlyStakeholder
    {
        uint256 _stakeholderIndex = stakeholderIndexes[msg.sender];
        Stake[] memory _stakes = stakeholders[_stakeholderIndex].stakes;
        Stake memory _stake = stakeholders[_stakeholderIndex].stakes[_stakeIndex];
        require(_stakeIndex < _stakes.length, "Staking: invalid index");
        require(_stake.locked > 0, "Staking: stake does not exist");
        require(block.timestamp - _stake.createdAt > _stake.duration, "Staking: stake is still locked");
        uint256 _locked = _stake.locked;
        uint256 _reward = calculateReward(_stake);
        stakeholders[_stakeholderIndex].stakes[_stakeIndex].locked = 0;
        stakeholders[_stakeholderIndex].stakes[_stakeIndex].unlocked = _locked;
        stakeholders[_stakeholderIndex].stakes[_stakeIndex].rewardClaimed = _reward;
        _mint(msg.sender, _locked + _reward);
        // TODO: emit StakeRemoved
    }

    function isStakeholder(address _stakeholder)
        public
        view
        returns (bool)
    {
        return stakeholderIndexes[_stakeholder] != 0;
    }

    function stakeholderCount()
        public
        view
        returns (uint256)
    {
        return stakeholders.length;
    }

    function hasRewardPlan(uint256 _duration, uint256 _rewardRate)
        public
        view
        returns (bool)
    {
        for (uint256 i = 0; i < rewardPlans.length; i++) {
            if (rewardPlans[i].duration == _duration && rewardPlans[i].rewardRate == _rewardRate) {
                return true;
            }
        }
        return false;
    }

    function createRewardPlan(uint256 _duration, uint256 _rewardRate)
        public
        onlyOwner
    {
        rewardPlans.push(RewardPlan({
            index: rewardPlans.length,
            duration: _duration,
            rewardRate: _rewardRate
        }));
    }

    function updateRewardPlan(uint256 _index, uint256 _duration, uint256 _rewardRate)
        public
        onlyOwner
    {
        require(_index < rewardPlans.length, "Staking: invalid index");
        rewardPlans[_index].duration = _duration;
        rewardPlans[_index].rewardRate = _rewardRate;
    }

    function removeRewardPlan(uint256 _index)
        public
        onlyOwner
    {
        require(_index < rewardPlans.length, "Staking: invalid index");
        rewardPlans[_index].duration = 0;
        rewardPlans[_index].rewardRate = 0;
    }

    function calculateReward(Stake memory _stake)
        internal
        view
        returns (uint256)
    {
        uint256 _rewardPerSecond = _stake.locked * _stake.rewardRate / 100 / 365 days;
        return (block.timestamp - _stake.createdAt) * _rewardPerSecond;
    }

    function register(address _stakeholder)
        internal
        returns (uint256)
    {
        stakeholders.push();
        uint256 index = stakeholders.length - 1;
        stakeholders[index].addr = _stakeholder;
        stakeholderIndexes[_stakeholder] = index;
        return index;
    }
}
