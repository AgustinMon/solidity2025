pragma solidity > 0.8.0;
// SPDX-License-Identifier: SEE LICENSE IN LICENSE
import @openzeppelin/contracts/access/Ownable.sol;
contract Oracle is Ownable {
    mapping(address => uint256) public prices;

    event PriceUpdated(address indexed asset, uint256 price);

    constructor() Ownable(msg.sender) {}

    function setPrice(address asset, uint256 price) public onlyOwner {
        prices[asset] = price;
        emit PriceUpdated(asset, price);
    }

    function getPrice(address asset) public view returns (uint256) {
        return prices[asset];
    }
}