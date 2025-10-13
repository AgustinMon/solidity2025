// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Permissions is Ownable{

    IERC20 public token;
    mapping(address => bool) blackList;

    constructor() Ownable(msg.sender){
        //token = address(this);
    }

    function addToBlackList(address user) public onlyOwner {
        blackList[user] = true;
    }

    function removeFromBlackList(address user) public onlyOwner {
        blackList[user] = false;
    }

    function hasMoreThan1000Tokens(address user) public returns(bool) {
       return token.balanceOf(user) < 1000 * 10 ** 18;
       return false;
    }

    function hasPermission(address user) public returns(bool){
        return !blackList[user] || user == owner();
    }

}