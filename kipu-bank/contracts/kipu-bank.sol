//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0; // Solidity 0.8.0+ revierte overflow/underflow automáticamente.

contract KipuBank {

    address immutable public owner; //public para generar transparencia
    uint256 public constant MINIMUMAMOUNT = 0.01 ether;

    mapping(address=>uint256) public balance; 
    
    error InvalidMinimum(string errorMessage);
    error Unauthorized(string errorMessage);
    error InvalidAmount(string errorMessage);

    event Deposited(address indexed  payer, uint256 amount);
    event WithDrawn(address indexed withdrawer, uint256 amount);

    modifier onlyOwner() {
        if(msg.sender != owner) revert Unauthorized("You are not the owner of the contract.");
        _;
    }

    constructor() {
        owner = msg.sender; //el valor de owner queda determinado en el deploy
    }

    function addAmount() external payable {
        /* 
            Add ether to your balance, only if the amount is greater 0.1 ether 
            Agrega dinero a tu balance, solo si la cantidad es mayor a 0.1 ether
        */
        if (msg.value < MINIMUMAMOUNT) revert InvalidMinimum("You must send at least 0.01 ether");
        balance[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value); //evento para web3
    }

    function withdrawPartialUsers(uint256 _amount) external returns (bytes memory) {
        /* 
            Funcion para que el msg.sender pueda retirar una cantidad parcial
            Function for the msg.sender to withdraw a partial amount
        */
        uint256 amount = _amount;
        uint256 userBalance = balance[msg.sender];
        //chequeo balance > amount en _substractBalance
        balance[msg.sender] = _substractBalance(userBalance,amount);
        // prevenido contra reentrancy attack
        (bool success, bytes memory data) = payable(msg.sender).call{value: amount}("");
        if (!success) {
            revert();
        }
        emit WithDrawn(msg.sender, amount); //evento para web3
        return data;
    }

    function getBalance() external view returns(uint256) {
        return balance[msg.sender];
    }

    function getTotalAllocated() external view returns(uint256) {
        /* 
            Function to get the total balance of the contract
            Funcion para obtener el valor total del contrato 
            Funcion para agregar transparencia publica
        */
        return address(this).balance; 
    }

    //FUNCIONES SOLO PARA EL OWNER DEL CONTRATO
    function withdrawAll(address _anyAddrress) external onlyOwner returns(bytes memory) {
        /* 
            Funcion para que el owner pueda devolver todo el balance de un contrato de terceros
            Function for the owner to withdraw and send all it balance to a third party address
            arguments: _anyAddrress = direccion del contrato de terceros
        */
        address to = _anyAddrress;
        uint256 userBalance = balance[_anyAddrress];
        balance[_anyAddrress] = _substractBalance(userBalance, userBalance);
        // prevenido contra reentrancy attack
        (bool success, bytes memory data) = to.call{value: userBalance}("");
        if(!success) revert();
        emit WithDrawn(msg.sender, userBalance); //evento para web3
        return data;
    }

    function withdrawPartialFromOwner(address _anyAddress, uint256 _amount) external onlyOwner returns (bytes memory) {
        /* 
            Funcion para que el owner pueda devolver una cantidad parcial de un contrato a terceros
            Function for the owner to withdraw a partial it amount to a third party address
            arguments: _anyAddress = direccion del contrato de terceros
                       _amount = cantidad a retirar
        */
        uint256 userBalance = balance[_anyAddress];
        //chequeo balance > amount en _substractBalance
        balance[_anyAddress] = _substractBalance(userBalance, _amount);
        // prevenido contra reentrancy attack
        (bool success, bytes memory data) = payable(_anyAddress).call{value: _amount}("");
        if (!success) {
            revert();
        }
        emit WithDrawn(_anyAddress, _amount); //evento para web3
        return data;
    }

    //FUNCIONES PRIVADAS
    function _substractBalance(uint256 _actualBalance, uint256 _amountToReduce) private pure returns (uint256) {
        /*
            Reduce el balanace de una direccion en una cantidad determinada
            Independientemente de que consume un poquito más gas, se decidió crear esta función para separar trabajos.
            Reduces the balance of an address by a determined amount
            Regardless of whether more gas is consumed, it was decided to create this function to separate tasks
            arguments: _actualBalance = balance actual de la direccion
                       _amountToReduce = cantidad a reducir
        */
        if (_actualBalance == 0) revert InvalidAmount("No balance to withdraw");
        if (_amountToReduce > _actualBalance) revert InvalidAmount("Invalid amount to withdraw");
        return _actualBalance - _amountToReduce;
    }
}