// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.31;

import {Test} from "forge-std/Test.sol";
import {MyToken} from "../../src/MyToken.sol";
import {DeployMyToken} from "../../script/DeployMyToken.s.sol";

contract MyTokenTest is Test {
    MyToken public myToken;
    DeployMyToken public deployer;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    uint256 public constant STARTING_BALANCE = 100 ether;

    function setUp() public {
        deployer = new DeployMyToken();
        myToken = deployer.run();

        vm.prank(msg.sender);
        myToken.transfer(bob, STARTING_BALANCE);
    }

    function test_BobBalance() public {
        assertEq(STARTING_BALANCE, myToken.balanceOf(bob));
    }

    function test_AllowancesWork() public {
        uint256 initialAllowance = 1000;

        // Bob approves Alice to spend tokens on his behalf.
        vm.prank(bob);
        myToken.approve(alice, initialAllowance);

        uint256 transferAmount = 500;

        vm.prank(alice);
        // If bob has approved, then below would be valid!
        myToken.transferFrom(bob, alice, transferAmount);

        assertEq(myToken.balanceOf(alice), transferAmount);
        assertEq(myToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
    }
}
