// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMeScript} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    function setUp() external {
        // Use that script to deploy fund and assign it into variable
        DeployFundMeScript deployFundMeScript = new DeployFundMeScript();
        fundMe = deployFundMeScript.run();
    }

    function testMinUsdIsFiveDollar() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testPriceFeedVersionIsAccurate() public view {
        assertEq(fundMe.getVersion(), 4);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.i_owner(), msg.sender);
    }
}
