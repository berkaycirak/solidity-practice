// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.31;

import {FundMe} from "../src/FundMe.sol";
import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {console} from "forge-std/console.sol";

contract DeployFundMeScript is Script {
    function run() external returns (FundMe) {
        // Before broadcast --> not a real tx
        HelperConfig helperConfig = new HelperConfig();
        address activePriceFeed = helperConfig.activeConfig();

        // After broadcst --> real tx which you pay gas
        vm.startBroadcast();
        FundMe fundMe = new FundMe(activePriceFeed);
        vm.stopBroadcast();

        return fundMe;
    }
}
