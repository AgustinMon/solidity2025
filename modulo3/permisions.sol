// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity > 0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Permisions is Ownable {
    IERC20 public token;
    address public ICO;
    mapping (address => bool) public blackList;

    constructor() Ownable(msg.sender) {}

    function hasPermission(address user) public view returns (bool) {
        // bug en la logica
        return !blackList[user] || user == owner();
    }

    function addToBlackList(address user) public onlyOwner {
        blackList[user] = true;
    }

    function removeFromBlackList(address user) public onlyOwner {
        blackList[user] = false;
    }

    function hasLessThan1000Tokens(address user) public view returns (bool) {
        return token.balanceOf(user) < 1000 * 10 ** 18;
    }
}