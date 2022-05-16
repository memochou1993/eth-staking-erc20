// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Staking is ERC20, Ownable {
    using SafeMath for uint256;

    uint256 public constant INITIAL_SUPPLY = 1e10;
    uint256 public rewardRate = 100;

    struct Stake {
        uint256 amount;
        uint256 rewardRate;
        uint256 claimable;
        uint256 startedAt;
    }

    struct Stakeholder {
        address addr;
        Stake[] stakes;
    }

    Stakeholder[] public stakeholders;
    mapping(address => uint256) public stakeholderIndexes;

    constructor() ERC20("My Token", "MTK") {
        stakeholders.push();
        _mint(msg.sender, INITIAL_SUPPLY);
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

    function stake(uint256 _amount)
        public
    {
        require(_amount > 0, "Cannot stake nothing");
        uint256 stakeholderIndex = stakeholderIndexes[msg.sender];
        uint256 timestamp = block.timestamp;
        if (!isStakeholder(msg.sender)) {
            stakeholderIndex = addStakeholder(msg.sender);
        }
        stakeholders[stakeholderIndex].stakes.push(Stake({
            amount: _amount,
            rewardRate: rewardRate,
            claimable: 0,
            startedAt: timestamp
        }));
        // emit Staked
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
        returns (Stake[] memory)
    {
        return stakeholders[stakeholderIndexes[msg.sender]].stakes;
    }
}
