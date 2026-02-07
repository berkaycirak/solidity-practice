// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.31;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {console} from "forge-std/console.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.01 ether;

    function fundFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Funded FundMe with,", SEND_VALUE);
    }

    function run() external {
        address mostRecentlyDeployed = 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512;
        fundFundMe(mostRecentlyDeployed);
    }
}

contract WithdrawFundMe is Script {}
