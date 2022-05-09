// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Staking is ERC20, Ownable {
    using SafeMath for uint256;

    uint256 public constant INITIAL_SUPPLY = 100000000;

    address[] internal stakeholders;

    mapping(address => uint256) internal balances; // TODO
    mapping(address => uint256) internal stakes;
    mapping(address => uint256) internal rewards;

    constructor() ERC20("My Token", "MTK") {
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    function createStake(uint256 _stake)
        public
    {
        _burn(msg.sender, _stake);
        if (stakes[msg.sender] == 0) {
            addStakeholder(msg.sender);
        }
        stakes[msg.sender] = stakes[msg.sender].add(_stake);
    }

    function removeStake(uint256 _stake)
        public
    {
        stakes[msg.sender] = stakes[msg.sender].sub(_stake);
        if (stakes[msg.sender] == 0) {
            removeStakeholder(msg.sender);
        }
        _mint(msg.sender, _stake);
    }

    function stakeOf(address _stakeholder)
        public
        view
        returns (uint256)
    {
        return stakes[_stakeholder];
    }

    function totalStakes()
        public
        view
        returns (uint256)
    {
        uint256 _totalStakes = 0;
        for (uint256 i = 0; i < stakeholders.length; i += 1) {
            _totalStakes = _totalStakes.add(stakes[stakeholders[i]]);
        }
        return _totalStakes;
    }

    function isStakeholder(address _address)
        public
        view
        returns (bool, uint256)
    {
        for (uint256 i = 0; i < stakeholders.length; i += 1) {
            if (_address == stakeholders[i]) {
                return (true, i);
            }
        }
        return (false, 0);
    }

    function addStakeholder(address _stakeholder)
        public
    {
        (bool _isStakeholder, ) = isStakeholder(_stakeholder);
        if (!_isStakeholder) {
            stakeholders.push(_stakeholder);
        }
    }

    function removeStakeholder(address _stakeholder)
        public
    {
        (bool _isStakeholder, uint256 s) = isStakeholder(_stakeholder);
        if (_isStakeholder) {
            stakeholders[s] = stakeholders[stakeholders.length - 1];
            stakeholders.pop();
        }
    }

    function rewardOf(address _stakeholder)
        public
        view
        returns (uint256)
    {
        return rewards[_stakeholder];
    }

    function totalRewards()
        public
        view
        returns (uint256)
    {
        uint256 _totalRewards = 0;
        for (uint256 i = 0; i < stakeholders.length; i += 1) {
            _totalRewards = _totalRewards.add(rewards[stakeholders[i]]);
        }
        return _totalRewards;
    }

    function calculateReward(address _stakeholder)
        public
        view
        returns (uint256)
    {
        return stakes[_stakeholder] / 100;
    }

    function withdrawReward()
        public
    {
        uint256 reward = rewards[msg.sender];
        rewards[msg.sender] = 0;
        _mint(msg.sender, reward);
    }

    function distributeRewards()
        public
        onlyOwner
    {
        for (uint256 i = 0; i < stakeholders.length; i += 1) {
            address stakeholder = stakeholders[i];
            rewards[stakeholder] = calculateReward(stakeholder);
        }
    }
}
