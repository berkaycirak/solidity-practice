// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.31;
import {Script} from "forge-std/Script.sol";
import {MyToken} from "../src/MyToken.sol";

contract DeployMyToken is Script {
    uint256 public constant INITIAL_SUPPLY = 1000 ether;
    MyToken myToken;

    function run() external returns (MyToken) {
        vm.startBroadcast();
        myToken = new MyToken(INITIAL_SUPPLY);
        vm.stopBroadcast();
        return myToken;
    }
}
