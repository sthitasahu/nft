// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {Test, console} from "forge-std/Test.sol";
import {Exchange} from "../src/Exchange.sol";
import {Token} from "../src/Token.sol";

contract ExchangeTest is Test {
    Exchange public exchange;
    Token public token1;
    Token public token2;
    
    address public feeAccount;
    uint256 public feePercent = 1; // 1%
    address public user1;
    address public user2;
    uint256 constant INITIAL_BALANCE = 1000e18;

    function setUp() public {
        // Deploy tokens
        token1 = new Token("Token 1", "TK1", 1000000e18);
        token2 = new Token("Token 2", "TK2", 1000000e18);

        // Setup accounts
        feeAccount = address(1);
        user1 = address(2);
        user2 = address(3);

        // Deploy exchange
        exchange = new Exchange(feeAccount, feePercent);

        // Transfer tokens to users
        token1.transfer(user1, INITIAL_BALANCE);
        token2.transfer(user2, INITIAL_BALANCE);
    }

    

}