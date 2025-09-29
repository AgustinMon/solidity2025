// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleStorage {
    uint256 private storedNumber; // la "cajita" donde guardamos el dato

    function setNumber(uint256 _newNumber) public {
        storedNumber = _newNumber; // escribir en la blockchain
    }

    function getNumber() public view returns (uint256) {
        return storedNumber;       // leer sin gastar gas
    }
}
