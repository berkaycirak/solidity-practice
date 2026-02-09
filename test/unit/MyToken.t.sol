// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.31;

import {Test} from "forge-std/Test.sol";
import {MyToken} from "../../src/MyToken.sol";
import {DeployMyToken} from "../../script/DeployMyToken.s.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

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

    // ============ Allowance Tests ============

    function test_ApproveSetsAllowance() public {
        uint256 allowanceAmount = 500;

        vm.prank(bob);
        myToken.approve(alice, allowanceAmount);

        assertEq(myToken.allowance(bob, alice), allowanceAmount);
    }

    function test_ApproveCanBeUpdated() public {
        uint256 initialAllowance = 500;
        uint256 newAllowance = 1000;

        vm.prank(bob);
        myToken.approve(alice, initialAllowance);
        assertEq(myToken.allowance(bob, alice), initialAllowance);

        vm.prank(bob);
        myToken.approve(alice, newAllowance);
        assertEq(myToken.allowance(bob, alice), newAllowance);
    }

    function test_TransferFromReducesAllowance() public {
        uint256 allowanceAmount = 1000;
        uint256 transferAmount = 300;

        vm.prank(bob);
        myToken.approve(alice, allowanceAmount);

        vm.prank(alice);
        myToken.transferFrom(bob, alice, transferAmount);

        assertEq(
            myToken.allowance(bob, alice),
            allowanceAmount - transferAmount
        );
    }

    function test_TransferFromFailsWithInsufficientAllowance() public {
        uint256 allowanceAmount = 100;
        uint256 transferAmount = 200;

        vm.prank(bob);
        myToken.approve(alice, allowanceAmount);

        vm.prank(alice);
        vm.expectRevert();
        myToken.transferFrom(bob, alice, transferAmount);
    }

    function test_TransferFromFailsWithoutApproval() public {
        vm.prank(alice);
        vm.expectRevert();
        myToken.transferFrom(bob, alice, 100);
    }

    function test_AllowanceIsZeroByDefault() public {
        assertEq(myToken.allowance(bob, alice), 0);
    }

    // ============ Transfer Tests ============

    function test_TransferWorks() public {
        uint256 transferAmount = 50 ether;
        address charlie = makeAddr("charlie");

        vm.prank(bob);
        myToken.transfer(charlie, transferAmount);

        assertEq(myToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
        assertEq(myToken.balanceOf(charlie), transferAmount);
    }

    function test_TransferFailsWithInsufficientBalance() public {
        uint256 transferAmount = STARTING_BALANCE + 1 ether;

        vm.prank(bob);
        vm.expectRevert();
        myToken.transfer(alice, transferAmount);
    }

    function test_TransferFailsToZeroAddress() public {
        vm.prank(bob);
        vm.expectRevert();
        myToken.transfer(address(0), 10 ether);
    }

    function test_TransferZeroAmount() public {
        vm.prank(bob);
        myToken.transfer(alice, 0);

        assertEq(myToken.balanceOf(bob), STARTING_BALANCE);
        assertEq(myToken.balanceOf(alice), 0);
    }

    function test_TransferToSelf() public {
        uint256 transferAmount = 10 ether;

        vm.prank(bob);
        myToken.transfer(bob, transferAmount);

        assertEq(myToken.balanceOf(bob), STARTING_BALANCE);
    }

    function test_TransferEmitsEvent() public {
        uint256 transferAmount = 10 ether;

        vm.expectEmit(true, true, false, true);
        emit IERC20.Transfer(bob, alice, transferAmount);

        vm.prank(bob);
        myToken.transfer(alice, transferAmount);
    }

    // ============ TransferFrom Tests ============

    function test_TransferFromWorks() public {
        uint256 allowanceAmount = 1000;
        uint256 transferAmount = 500;

        vm.prank(bob);
        myToken.approve(alice, allowanceAmount);

        vm.prank(alice);
        myToken.transferFrom(bob, alice, transferAmount);

        assertEq(myToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
        assertEq(myToken.balanceOf(alice), transferAmount);
        assertEq(
            myToken.allowance(bob, alice),
            allowanceAmount - transferAmount
        );
    }

    function test_TransferFromFailsWithInsufficientBalance() public {
        uint256 allowanceAmount = STARTING_BALANCE + 1 ether;

        vm.prank(bob);
        myToken.approve(alice, allowanceAmount);

        vm.prank(alice);
        vm.expectRevert();
        myToken.transferFrom(bob, alice, allowanceAmount);
    }

    function test_TransferFromFailsToZeroAddress() public {
        uint256 allowanceAmount = 1000;

        vm.prank(bob);
        myToken.approve(alice, allowanceAmount);

        vm.prank(alice);
        vm.expectRevert();
        myToken.transferFrom(bob, address(0), 100);
    }

    function test_TransferFromEmitsEvent() public {
        uint256 allowanceAmount = 1000;
        uint256 transferAmount = 500;

        vm.prank(bob);
        myToken.approve(alice, allowanceAmount);

        vm.expectEmit(true, true, false, true);
        emit IERC20.Transfer(bob, alice, transferAmount);

        vm.prank(alice);
        myToken.transferFrom(bob, alice, transferAmount);
    }

    function test_ApproveEmitsEvent() public {
        uint256 allowanceAmount = 1000;

        vm.expectEmit(true, true, false, true);
        emit IERC20.Approval(bob, alice, allowanceAmount);

        vm.prank(bob);
        myToken.approve(alice, allowanceAmount);
    }

    // ============ Other Important Tests ============

    function test_TotalSupply() public {
        assertEq(myToken.totalSupply(), 1000 ether);
    }

    function test_Name() public {
        assertEq(myToken.name(), "MyToken");
    }

    function test_Symbol() public {
        assertEq(myToken.symbol(), "MT");
    }

    function test_Decimals() public {
        assertEq(myToken.decimals(), 18);
    }

    function test_DeployerBalance() public {
        uint256 expectedBalance = 1000 ether - STARTING_BALANCE;
        assertEq(myToken.balanceOf(msg.sender), expectedBalance);
    }

    function test_MultipleTransfers() public {
        address charlie = makeAddr("charlie");
        address dave = makeAddr("dave");

        vm.prank(bob);
        myToken.transfer(alice, 10 ether);

        vm.prank(bob);
        myToken.transfer(charlie, 20 ether);

        vm.prank(alice);
        myToken.transfer(dave, 5 ether);

        assertEq(myToken.balanceOf(bob), STARTING_BALANCE - 30 ether);
        assertEq(myToken.balanceOf(alice), 5 ether);
        assertEq(myToken.balanceOf(charlie), 20 ether);
        assertEq(myToken.balanceOf(dave), 5 ether);
    }

    function test_MultipleApprovals() public {
        address charlie = makeAddr("charlie");

        vm.prank(bob);
        myToken.approve(alice, 100);

        vm.prank(bob);
        myToken.approve(charlie, 200);

        assertEq(myToken.allowance(bob, alice), 100);
        assertEq(myToken.allowance(bob, charlie), 200);
    }

    function test_TransferFromFullAllowance() public {
        uint256 allowanceAmount = STARTING_BALANCE;

        vm.prank(bob);
        myToken.approve(alice, allowanceAmount);

        vm.prank(alice);
        myToken.transferFrom(bob, alice, allowanceAmount);

        assertEq(myToken.balanceOf(bob), 0);
        assertEq(myToken.balanceOf(alice), STARTING_BALANCE);
        assertEq(myToken.allowance(bob, alice), 0);
    }
}
