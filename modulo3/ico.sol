// SPDX-License-Identifier: SEE LICENSE IN LICENSE 
pragma solidity > 0.8.0;

import "./token.sol";

contract Ico {

    error TransferFailed();
    error NoPermission(address user);

    event TokenBought(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
    event TokenSold(address seller, uint256 amountOfTokens, uint256 amountOfETH);
    
    Token public token;
    address public owner;
    uint256 public rate; // Number of tokens per ether

    constructor(Token _token, uint256 _rate) {
        token = _token;
        owner = msg.sender;
        rate = _rate;

    }

    function buyTokens() public payable {

        uint256 tokenAmount = msg.value / rate;

        require(msg.value > 0, "Send ETH to buy tokens");
        require(token.balanceOf(address(this)) >= tokenAmount, "Not enough tokens in ICO contract");

        token.transfer(msg.sender, tokenAmount);
        emit TokenBought(msg.sender, msg.value, tokenAmount);
    }

    function getTokenContractBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function sellTokens(uint256 tokenAmount) public {
 
        require(tokenAmount > 0, "Specify an amount of tokens to sell");
        require(token.balanceOf(msg.sender) >= tokenAmount, "You do not have enough tokens");

        uint256 etherAmount = (tokenAmount * rate * 98) / 100; // 2% fee
        require(address(this).balance >= etherAmount, "Not enough ETH in ICO contract");

        token.transferFrom(msg.sender, address(this), tokenAmount);
        (bool success,)= msg.sender.call{value:etherAmount}("");
        if (!success) revert TransferFailed();
        emit TokenSold(msg.sender, tokenAmount, etherAmount);
    }

}