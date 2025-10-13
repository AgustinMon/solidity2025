// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

import "./token.sol";

interface myOracle {
    function getTokenPrice() external view returns (uint256);
    function getEthPrice() external view returns (uint256);
}

contract Ico {
    event TokensSold(address indexed buyer, uint256 ethPaid, uint256 tokensReceived);
    event TokensBought(address indexed seller, uint256 tokensSold, uint256 ethReturned);

    error NotEnoughTokens();
    error AmountIsZero();

    myOracle public immutable oracle;
    Token public immutable token;

    constructor(Token _token, myOracle _oracle) {
        oracle = _oracle;
        token = _token;
    }

    /**
     * 🟢 Comprar tokens (pagando en ETH)
     */
    function buyTokens() external payable {
        if (msg.value == 0) revert AmountIsZero();

        uint256 tokenPrice = oracle.getTokenPrice(); 
        uint256 ethPrice = oracle.getEthPrice();     

        // tokens = (ETH enviado * precio ETH) / precio token
        uint256 tokensToBuy = (msg.value * ethPrice) / tokenPrice;

        // transferir tokens desde el contrato ICO hacia el comprador
        if (token.balanceOf(address(this)) < tokensToBuy) revert NotEnoughTokens();

        token.transfer(msg.sender, tokensToBuy);

        emit TokensBought(msg.sender, tokensToBuy, msg.value);
    }

    /**
     * 🔴 Vender tokens (recibir ETH a cambio)
     */
    function sellTokens(uint256 tokenAmount) external {
        if (tokenAmount == 0) revert AmountIsZero();

        uint256 tokenPrice = oracle.getTokenPrice();
        uint256 ethPrice = oracle.getEthPrice();

        // ETH equivalente menos 2% de comisión
        uint256 ethToSend = ((tokenAmount * tokenPrice) / ethPrice) * 98 / 100;

        // Transfiere tokens del usuario al contrato
        bool success = token.transferFrom(msg.sender, address(this), tokenAmount);
        require(success, "TransferFrom failed");

        // Envía ETH al vendedor
        (bool sent, ) = msg.sender.call{value: ethToSend}("");
        require(sent, "ETH transfer failed");

        emit TokensSold(msg.sender, ethToSend, tokenAmount);
    }

    // Permitir que el contrato reciba ETH
    receive() external payable {}
}
