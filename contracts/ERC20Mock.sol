// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20Mock is ERC20 {
    uint256 private _totalSupply = 1e9 * 1e18;

    constructor() ERC20("ERC20Mock", "M20") {
        _mint(msg.sender, _totalSupply);
    }
}
