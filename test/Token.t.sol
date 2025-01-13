// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import   {Token} from "../src/Token.sol";

contract TokenTest is Test {
    Token token;
    address deployer = address(1);
    address receiver = address(2);
    address spender = address(3);
    uint256 initialSupply = 1_000_000 ether;

    // Events matching the Token contract
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function setUp() public {
        vm.startPrank(deployer);
        token = new Token("Test Token", "TST", 1_000_000);
        vm.stopPrank();
    }

    function testDeployment() public {
        assertEq(token.name(), "Test Token");
        assertEq(token.symbol(), "TST");
        assertEq(token.decimals(), 18);
        assertEq(token.totalSupply(), initialSupply);
        assertEq(token.balances(deployer), initialSupply);
    }

    function testApproveSuccess() public {
        vm.startPrank(deployer);

        uint256 amount = 100 ether;
        vm.expectEmit(true, true, true, true);
        emit Approval(deployer, spender, amount);
        bool success = token.approve(spender, amount);

        assertTrue(success);
        assertEq(token.allowance(deployer, spender), amount);

        vm.stopPrank();
    }

    function testApproveFailInvalidSpender() public {
        vm.startPrank(deployer);

        uint256 amount = 100 ether;
        vm.expectRevert(bytes("Invalid spender address"));
        token.approve(address(0), amount);

        vm.stopPrank();
    }

    function testTransferSuccess() public {
        vm.startPrank(deployer);

        uint256 amount = 100 ether;
        vm.expectEmit(true, true, true, true);
        emit Transfer(deployer, receiver, amount);
        bool success = token.transfer(receiver, amount);

        assertTrue(success);
        assertEq(token.balances(deployer), initialSupply - amount);
        assertEq(token.balances(receiver), amount);

        vm.stopPrank();
    }

    function testTransferFailInsufficientBalance() public {
        vm.startPrank(receiver);

        uint256 amount = 100 ether;
        vm.expectRevert(bytes("Insufficient balance"));
        token.transfer(deployer, amount);

        vm.stopPrank();
    }

    function testTransferFailInvalidRecipient() public {
        vm.startPrank(deployer);

        uint256 amount = 100 ether;
        vm.expectRevert(bytes("Invalid recipient address"));
        token.transfer(address(0), amount);

        vm.stopPrank();
    }

    function testTransferFromSuccess() public {
        vm.startPrank(deployer);

        uint256 amount = 100 ether;
        token.approve(spender, amount);
        vm.stopPrank();

        vm.startPrank(spender);
        vm.expectEmit(true, true, true, true);
        emit Transfer(deployer, receiver, amount);
        bool success = token.transferFrom(deployer, receiver, amount);

        assertTrue(success);
        assertEq(token.balances(deployer), initialSupply - amount);
        assertEq(token.balances(receiver), amount);
        assertEq(token.allowance(deployer, spender), 0);

        vm.stopPrank();
    }

    function testTransferFromFailExceedsAllowance() public {
        vm.startPrank(deployer);

        uint256 amount = 100 ether;
        token.approve(spender, amount);
        vm.stopPrank();

        vm.startPrank(spender);
        uint256 invalidAmount = 200 ether; // Exceeding allowance
        vm.expectRevert(bytes("Allowance exceeded"));
        token.transferFrom(deployer, receiver, invalidAmount);

        vm.stopPrank();
    }

    function testTransferFromFailExceedsBalance() public {
        vm.startPrank(deployer);

        uint256 amount = 100 ether;
        token.approve(spender, amount);
        vm.stopPrank();

        vm.startPrank(spender);
        vm.expectRevert(bytes("Insufficient balance"));
        token.transferFrom(deployer, receiver, initialSupply + 1 ether);

        vm.stopPrank();
    }

    function testTransferFromFailInvalidRecipient() public {
        vm.startPrank(deployer);

        uint256 amount = 100 ether;
        token.approve(spender, amount);
        vm.stopPrank();

        vm.startPrank(spender);
        vm.expectRevert(bytes("Invalid recipient address"));
        token.transferFrom(deployer, address(0), amount);

        vm.stopPrank();
    }
}