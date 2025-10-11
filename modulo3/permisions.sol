// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity > 0.8.0;

import @openzeppelin/contracts/access/Ownable.sol;

contract Permisions is Ownable {
    Token public token;
    mappng (address => bool) public blackList;

    Constructor(Token _token) Ownable(token.owner()) {
        token = _token;
    }

    function hasPermission(address user) public view returns (bool) {
        // bug en la logica
        return blackList[user] || user == owner();
    }

    function addToBlackList(address user) public onlyOwner {
        blackList[user] = true;
    }

    function removeFromBlackList(address user) public onlyOwner {
        blackList[user] = false;
    }

    function hasLessThan1000Tokens(address user) public view returns (bool) {
        return token.balanceOf(user) < 1000 * 10 ** token.decimals();
    }
}