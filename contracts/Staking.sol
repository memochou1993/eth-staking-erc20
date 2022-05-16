// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Staking is ERC20, Ownable {
    using SafeMath for uint256;

    uint256 public constant INITIAL_SUPPLY = 1e10;
    uint256 public rewardRate = 100;

    struct Stakeholder {
        address addr;
        Stake[] stakes;
    }

    struct Stake {
        uint256 amount;
        uint256 rewardRate;
        uint256 claimable;
        uint256 startedAt;
    }

    Stakeholder[] public stakeholders;
    mapping(address => uint256) public stakeholderIndexes;

    constructor() ERC20("My Token", "MTK") {
        stakeholders.push();
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    modifier onlyStakeholder() {
        require(isStakeholder(msg.sender), "Staking: caller is not the stakeholder");
        _;
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

    function createStake(uint256 _amount)
        public
    {
        require(_amount > 0, "Staking: cannot stake nothing");
        uint256 _stakeholderIndex = stakeholderIndexes[msg.sender];
        uint256 _timestamp = block.timestamp;
        if (!isStakeholder(msg.sender)) {
            _stakeholderIndex = addStakeholder(msg.sender);
        }
        stakeholders[_stakeholderIndex].stakes.push(Stake({
            amount: _amount,
            rewardRate: rewardRate,
            claimable: 0,
            startedAt: _timestamp
        }));
        _burn(msg.sender, _amount);
        // emit StakeCreated
    }

    function removeStake(uint256 _stakeIndex)
        public
        onlyStakeholder
    {
        uint256 _stakeholderIndex = stakeholderIndexes[msg.sender];
        Stake[] memory _stakes = stakeholders[_stakeholderIndex].stakes;
        require(_stakeIndex < _stakes.length, "Staking: invalid stake ID");
        Stake memory _stake = _stakes[_stakeIndex];
        require(_stake.amount > 0, "Staking: stake does not exist");
        uint256 _reward = calculateReward(_stake);
        delete stakeholders[_stakeholderIndex].stakes[_stakeIndex];
        _mint(msg.sender, _stake.amount + _reward);
        // emit StakeRemoved
    }

    function isStakeholder(address _stakeholder)
        public
        view
        returns (bool)
    {
        return stakeholderIndexes[_stakeholder] != 0;
    }

    function stakes()
        public
        view
        onlyStakeholder
        returns (Stake[] memory)
    {
        uint256 _stakeholderIndex = stakeholderIndexes[msg.sender];
        return stakeholders[_stakeholderIndex].stakes;
    }

    function addStakeholder(address _stakeholder)
        internal
        returns (uint256)
    {
        stakeholders.push();
        uint256 index = stakeholders.length - 1;
        stakeholders[index].addr = _stakeholder;
        stakeholderIndexes[_stakeholder] = index;
        return index;
    }

    function calculateReward(Stake memory _stake)
        internal
        view
        returns (uint256)
    {
        uint256 _rewardPerSecond = _stake.amount * _stake.rewardRate / 100 / 365 / 86400;
        return (block.timestamp - _stake.startedAt) * _rewardPerSecond;
    }
}
