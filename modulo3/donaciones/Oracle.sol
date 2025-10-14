// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0; /// Solidity 0.8.0+ rev

import {IOracle} from "./IOracle.sol";

contract Oracle {
    
    function latestAnswer() external pure returns (int256){
        return 41178870000; // Simulamos un precio fijo de 2000 USDC por ETH
    }

}