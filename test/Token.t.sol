// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Token} from "../src/Token.sol";

contract TokenTest is Test {
    Token token;
    address deployer;
    address receiver;
    address exchange;

    uint256 constant initialSupply = 1_000_000 ether;

    function setUp() public {
        deployer = address(0x1);
        receiver = address(0x2);
        exchange = address(0x3);

        vm.startPrank(deployer);
        token = new Token("Dapp University", "DAPP", initialSupply);
        vm.stopPrank();
    }

    function testDeployment() public {
        assertEq(token.name(), "Dapp University");
        assertEq(token.symbol(), "DAPP");
        assertEq(token.decimals(), 18);
        assertEq(token.totalSupply(), initialSupply);
        
    }

    function testTransferSuccess() public {
        uint256 amount = 100 ether;

        vm.startPrank(deployer);
        token.transfer(receiver, amount);
        vm.stopPrank();

        assertEq(token.balanceOf(deployer), initialSupply - amount);
        assertEq(token.balanceOf(receiver), amount);
    }

    function testTransferEmitEvent() public {
        uint256 amount = 100 ether;

        vm.startPrank(deployer);
        vm.expectEmit(true, true, true, true);
        emit Token.Transfer(deployer, receiver, amount);
        token.transfer(receiver, amount);
        vm.stopPrank();
    }

    function testTransferFailInsufficientBalance() public {
        uint256 invalidAmount = 1_000_000_000 ether; // More than the total supply

        vm.startPrank(deployer);
        vm.expectRevert();
        token.transfer(receiver, invalidAmount);
        vm.stopPrank();
    }

    function testTransferFailInvalidRecipient() public {
        uint256 amount = 100 ether;

        vm.startPrank(deployer);
        vm.expectRevert();
        token.transfer(address(0), amount);
        vm.stopPrank();
    }

    function testApproveSuccess() public {
        uint256 amount = 100 ether;

        vm.startPrank(deployer);
        token.approve(exchange, amount);
        vm.stopPrank();

        assertEq(token.allowance(deployer, exchange), amount);
    }

    function testApproveEmitEvent() public {
        uint256 amount = 100 ether;

        vm.startPrank(deployer);
        vm.expectEmit(true, true, true, true);
        emit Token.Approval(deployer, exchange, amount);
        token.approve(exchange, amount);
        vm.stopPrank();
    }

    function testApproveFailInvalidSpender() public {
        uint256 amount = 100 ether;

        vm.startPrank(deployer);
        vm.expectRevert();
        token.approve(address(0), amount);
        vm.stopPrank();
    }

    function testTransferFromSuccess() public {
        uint256 amount = 100 ether;

        // Approve exchange
        vm.startPrank(deployer);
        token.approve(exchange, amount);
        vm.stopPrank();

        // Transfer from deployer to receiver
        vm.startPrank(exchange);
        token.transferFrom(deployer, receiver, amount);
        vm.stopPrank();

        assertEq(token.balanceOf(deployer), initialSupply - amount);
        assertEq(token.balanceOf(receiver), amount);
        assertEq(token.allowance(deployer, exchange), 0);
    }

    function testTransferFromEmitEvent() public {
        uint256 amount = 100 ether;

        // Approve exchange
        vm.startPrank(deployer);
        token.approve(exchange, amount);
        vm.stopPrank();

        // Expect Transfer event
        vm.startPrank(exchange);
        vm.expectEmit(true, true, true, true);
        emit Token.Transfer(deployer, receiver, amount);
        token.transferFrom(deployer, receiver, amount);
        vm.stopPrank();
    }

    function testTransferFromFailInsufficientAllowance() public {
        uint256 amount = 100 ether;

        // Attempt to transfer without approval
        vm.startPrank(exchange);
        vm.expectRevert();
        token.transferFrom(deployer, receiver, amount);
        vm.stopPrank();
    }

    function testTransferFromFailInsufficientBalance() public {
        uint256 amount = initialSupply + 1;

        // Approve exchange
        vm.startPrank(deployer);
        token.approve(exchange, amount);
        vm.stopPrank();

        // Attempt transfer exceeding balance
        vm.startPrank(exchange);
        vm.expectRevert();
        token.transferFrom(deployer, receiver, amount);
        vm.stopPrank();
    }
}