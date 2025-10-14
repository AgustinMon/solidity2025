// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0; /// Solidity 0.8.0+ revierte overflow/underflow automáticamente.

import {IOracle} from "./IOracle.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {GreatInvestor} from "./GreatInverstor.sol";

contract Donations {

    struct Balances{
        uint256 eth;
        uint256 usdc;
        uint256 total;
    }
    IERC20 immutable public USDC;
    mapping (address => Balances) public balance;

    IOracle public oracle;

    constructor(IOracle _oracle, IERC20 _usdc) GreatInvestor(msg.sender){//greatinvestor recibe initialowner
        USDC = _usdc;
        oracle = _oracle;
    }

    function doeETH() external payable{
        int256 _latestanswer = _getETHPrice();
        balance[msg.sender].eth += msg.value;
        balance[msg.sender].total += (msg.value * uint256(_latestanswer))/1e8;
    }

    function doeUSDC(uint256 amount) external {
        int256 _latestanswer = _getETHPrice();
        USDC.transferFrom(msg.sender, address(this), amount);
        balance[msg.sender].usdc += amount;
        balance[msg.sender].total += (amount * 1e8)/uint256(_latestanswer);
        if(balance[msg.sender].total > 1000 * 100000000 * 1 ether){//26 ceros
           if (balanceOf[msg.sender] < 1) GreatInverstor.safeMint(msg.sender, "url");
        }
    }

    function saque() external onlyOwner{
        //solo el owner puede sacar
        payable(owner()).transfer(address(this).balance);
        USDC.transfer(owner(), USDC.balanceOf(address(this)));
        //saca eth
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        if(!success) {
            revert("Transfer failed.");
        }   
    }

    function setFeeds(address _feed) external {
        oracle = IOracle(_feed);//revisar casting
    }

    function _getETHPrice() internal view returns (int256) {
        return oracle.latestAnswer();
    }
}