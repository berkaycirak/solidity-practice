// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMeScript} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether; // 100000000000000000 wei

    function setUp() external {
        // Use that script to deploy fund and assign it into variable
        DeployFundMeScript deployFundMeScript = new DeployFundMeScript();
        fundMe = deployFundMeScript.run();
        vm.deal(USER, SEND_VALUE);
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

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert(); // Next nline should revert;

        fundMe.fund(); // send 0 value
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }
}
