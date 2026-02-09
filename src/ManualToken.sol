// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.31;

contract ManualToken {
    mapping(address => uint256) private s_balances; // storage for addresses and their associated balances. Mapping data structure for fast access

    // function name() public pure returns (string memory) {
    //     return "My Token";
    // }

    string public name = "My Token";

    function totalSupply() public pure returns (uint256) {
        return 100 ether; // 100 * 10^18
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return s_balances[_owner];
    }

    function transfer(address _to, uint256 _amount) public {
        uint256 prevBalances = balanceOf(msg.sender) + balanceOf(_to);
        s_balances[msg.sender] -= _amount;
        s_balances[_to] += _amount;

        require(balanceOf(msg.sender) + balanceOf(_to) == prevBalances);
    }
}
