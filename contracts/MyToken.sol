// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    uint256 private _totalSupply = 1e10;

    constructor() ERC20("My Token", "MTK") {
        _mint(msg.sender, _totalSupply);
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
}
