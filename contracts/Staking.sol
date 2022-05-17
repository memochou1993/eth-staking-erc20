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
        uint256 index;
        uint256 amount;
        uint256 rewardRate;
        uint256 createdAt;
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

    modifier validStakeIndex(uint256 _stakeIndex) {
        uint256 _stakeholderIndex = stakeholderIndexes[msg.sender];
        Stake[] memory _stakes = stakeholders[_stakeholderIndex].stakes;
        require(_stakeIndex < _stakes.length && _stakes[_stakeIndex].amount > 0, "Staking: stake does not exist");
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
            amount: _amount,
            rewardRate: rewardRate,
            createdAt: block.timestamp
        }));
        _burn(msg.sender, _amount);
        // TODO: emit StakeCreated
    }

    function withdraw(uint256 _stakeIndex)
        public
        onlyStakeholder
        validStakeIndex(_stakeIndex)
    {
        uint256 _stakeholderIndex = stakeholderIndexes[msg.sender];
        Stake memory _stake = stakeholders[_stakeholderIndex].stakes[_stakeIndex];
        uint256 _amount = _stake.amount;
        uint256 _reward = calculateReward(_stake);
        stakeholders[_stakeholderIndex].stakes[_stakeIndex].amount = 0;
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

    function stakes()
        public
        view
        onlyStakeholder
        returns (Stake[] memory)
    {
        uint256 _stakeholderIndex = stakeholderIndexes[msg.sender];
        return stakeholders[_stakeholderIndex].stakes;
    }

    function calculateReward(Stake memory _stake)
        internal
        view
        onlyStakeholder
        returns (uint256)
    {
        uint256 _rewardPerSecond = _stake.amount * _stake.rewardRate / 100 / 365 / 86400;
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
