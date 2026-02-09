// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.31;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Since ERC20 has its own "constructor", we should pass its parameters by calling ERC20 after our constructor. This is like "super()" in Javascript to call parent class constructor first
contract MyToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("MyToken", "MT") {
        _mint(msg.sender, initialSupply);
    }
}
