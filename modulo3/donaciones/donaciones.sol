// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0; /// Solidity 0.8.0+ revierte overflow/underflow automáticamente.

import {Oracle} from "./Oracle.sol";
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
    Oracle immutable public datafeed;

    error invalidContract();
    error trnsferFailed();
    error invalidAmount();

    event FeedSet(address oracle, uint256 timestamp);

    constructor(Oracle _oracle, IERC20 _usdc) GreatInvestor(msg.sender){//greatinvestor recibe initialowner
        if(address(_oracle) == address(0) || address(_usdc) == address(0)) revert invalidContract;
        USDC = _usdc;
        datafeed = _oracle;
        emit FeedSet(address(_oracle), block.timestamp);
    }

    function doeETH() external payable{
        int256 _latestanswer = datafeed._getETHPrice();
        Balances storage _balance = _balance[msg.sender];
        uint256 _donatedInUSDC = 0;
        _donatedInUSDC += _balance.total;
        balance[msg.sender].eth += msg.value;
        balance[msg.sender].total += (msg.value * uint256(_latestanswer))/1e8;
    }

    function doeUSDC(uint256 _usdcamount) external {
        USDC.transferFrom(msg.sender, address(this), amount);
        Balances storage _balance = _balance[msg.sender];
        _balance.usdc += _usdcamount;

        int256 _latestanswer = datafeed._getETHPrice();
        //si latestanswer = 0 revert
        if(_latestanswer <= 0) revert invalidAmount();

        _balance.total += (amount * 1e8)/uint256(_latestanswer);
        
        if(_balance.total > 1000 * 100000000 * 1 ether){//26 ceros
           if (balanceOf[msg.sender] < 1) GreatInverstor.safeMint(msg.sender, "url");
        }

        emit Donated();
    }

    function saque() external onlyOwner{
        //solo el owner puede sacar
        //chequear balances
        payable(owner()).transfer(address(this).balance);
        USDC.transfer(owner(), USDC.balanceOf(address(this)));
        //saca eth
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        if(!success) {
            revert transferFailed(); 
        }   
    }

    function setFeeds(address _feed) external {
        //comprobaciones
        if(msg.value == 0) revert invalidAmount();
        if(_feed == address(0)) revert invalidContract();
        oracle = IOracle(_feed);//revisar casting
    }
}