// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0; /// Solidity 0.8.0+ rev

interface IOracle {
    function latestAnswer() external view returns (int256);

}