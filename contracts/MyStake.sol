// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract MyStake is ERC20, Ownable {
    using SafeMath for uint256;

    uint256 public constant INITIAL_SUPPLY = 1e10;

    struct Stakeholder {
        address addr;
        Stake[] stakes;
    }

    struct RewardPlan {
        uint256 index;
        string name;
        uint256 duration;
        uint256 rewardRate;
        uint256 deletedAt;
    }

    struct Stake {
        uint256 index;
        uint256 amount;
        uint256 rewardClaimed;
        RewardPlan rewardPlan;
        uint256 lockedAt;
        uint256 unlockedAt;
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

    modifier validRewardPlanIndex(uint256 _index) {
        require(_index < rewardPlans.length, "Staking: reward plan does not exist");
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

    function deposit(uint256 _amount, uint256 _rewardPlanIndex)
        public
        validRewardPlanIndex(_rewardPlanIndex)
    {
        require(_amount > 0, "Staking: amount cannot be zero");
        RewardPlan memory _rewardPlan = rewardPlans[_rewardPlanIndex];
        require(_rewardPlan.deletedAt == 0, "Staking: reward plan does not exist");
        uint256 _stakeholderIndex = stakeholderIndexes[msg.sender];
        if (!isStakeholder(msg.sender)) {
            _stakeholderIndex = register(msg.sender);
        }
        stakeholders[_stakeholderIndex].stakes.push(Stake({
            index: stakeholders[_stakeholderIndex].stakes.length,
            amount: _amount,
            rewardClaimed: 0,
            rewardPlan: _rewardPlan,
            lockedAt: block.timestamp,
            unlockedAt: 0
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
        require(_stakeIndex < _stakes.length, "Staking: stake does not exist");
        Stake memory _stake = _stakes[_stakeIndex];
        uint256 _amount = _stake.amount;
        require(_stake.unlockedAt == 0, "Staking: stake does not exist");
        require(block.timestamp - _stake.lockedAt > _stake.rewardPlan.duration, "Staking: stake is still locked");
        uint256 _reward = calculateReward(_stake);
        stakeholders[_stakeholderIndex].stakes[_stakeIndex].rewardClaimed = _reward;
        stakeholders[_stakeholderIndex].stakes[_stakeIndex].unlockedAt = block.timestamp;
        _mint(msg.sender, _amount + _reward);
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

    function createRewardPlan(string memory _name, uint256 _duration, uint256 _rewardRate)
        public
        onlyOwner
    {
        require(_duration > 0, "Staking: duration cannot be zero");
        require(_rewardRate > 0, "Staking: reward rate cannot be zero");
        rewardPlans.push(RewardPlan({
            index: rewardPlans.length,
            name: _name,
            duration: _duration,
            rewardRate: _rewardRate,
            deletedAt: 0
        }));
    }

    function updateRewardPlan(uint256 _index, string memory _name)
        public
        onlyOwner
        validRewardPlanIndex(_index)
    {
        rewardPlans[_index].name = _name;
    }

    function removeRewardPlan(uint256 _index)
        public
        onlyOwner
        validRewardPlanIndex(_index)
    {
        require(rewardPlans[_index].deletedAt == 0, "Staking: reward plan does not exist");
        rewardPlans[_index].deletedAt = block.timestamp;
    }

    function calculateReward(Stake memory _stake)
        internal
        pure
        returns (uint256)
    {
        return _stake.rewardPlan.duration * _stake.amount * _stake.rewardPlan.rewardRate / 100 / 365 days;
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
