//SPDX-License-Identifier:MIT LICENSE
pragma solidity ^0.8.3;
import "./Token.sol";
contract Exchange{

    address public feeAddress;
    uint256 public feePercent;
    mapping(address=>mapping(address=>uint256)) public tokens;
   

    event Deposit(
        address user,
        address token,
        uint256 amount,
        uint256 balance
    );

    event Withdraw(
        address user,
        address token,
        uint256 amount,
        uint256 balance
    );

    constructor(address _feesaddress,uint256 _feespercent){
        feeAddress=_feesaddress;
        feePercent=_feespercent;
    }

    function deposit (address token, uint256 amount) public {
        require(Token(token).transferFrom(msg.sender,address(this),amount));
        tokens[token][msg.sender]+=amount;
        emit Deposit(msg.sender,token,amount,tokens[token][msg.sender]);
    }

    function withdraw(address token,uint256 amount) public {
        require(tokens[token][msg.sender]>=amount,"Insufficient balance");
        Token(token).transfer(msg.sender,amount);
        tokens[token][msg.sender]-=amount;
        emit Withdraw(msg.sender,token,amount,tokens[token][msg.sender]);
    }

}