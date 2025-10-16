// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0; /// Solidity 0.8.0+ rev

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {IOracle} from "./IOracle.sol";

contract Oracle {
    
    function latestAnswer() external pure returns (int256){
        return 41178870000; // Simulamos un precio fijo de 2000 USDC por ETH
    }

    function _getETHPrice() internal view returns (int256) {
        (
            //uint80 roundId,
            int256 answer,      // ← ESTE es el precio
            //uint256 startedAt,
            //uint256 updatedAt,
            //uint80 answeredInRound
        ) = datafeed.latestRoundData();
        return answer;
    }



}