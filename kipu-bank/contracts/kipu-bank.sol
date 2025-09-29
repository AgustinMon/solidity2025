pragma solidity >0.8.0;

//SPDX-License-Identifier: UNLICENSED

contract KipuBank {

    address immutable public owner; //public para generar transparencia
    uint256 private MINIMUMAMOUNT = 0.01 ether;

    mapping(address=>uint256) public balance; 
    
    error InvalidMinimum(string errorMessage);
    error Unauthorized(string errorMessage);
    error InvalidAmmount(string errorMessage);

    event onPaid(address indexed  payer, uint256 amount);
    event onWithdraw(address indexed withdrawer, uint256 amount);

    modifier onlyOwner() {
        if(msg.sender != owner) revert Unauthorized("You are not the owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addAmmount() external payable {
        /* 
            Add ether to your balance, only if the amount is greater 0.1 ether 
            Agrega dinero a tu balance, solo si la cantidad es mayor a 0.1 ether
        */
        if (msg.value < MINIMUMAMOUNT) revert InvalidMinimum("You must send at least 0.01 ether");
        balance[msg.sender] += msg.value;
        emit onPaid(msg.sender, msg.value); //evento para web3
    }

    function withdrawPartial(uint256 _amount) external returns (bytes memory) {
        /* funcion para que el msg.sender pueda retirar una cantidad parcial
           function for the msg.sender to withdraw a partial amount
        */
        uint256 amount = _amount;
        uint256 userBalance = balance[msg.sender];
        if (amount > userBalance) {
            revert InvalidAmmount("Invalid ammount to withdraw");
        }

        balance[msg.sender] = userBalance - amount;

        (bool success, bytes memory data) = payable(msg.sender).call{value: amount}("");
        if (!success) {
            revert();
        }
        emit onWithdraw(msg.sender, amount); //evento para web3
        if(balance[msg.sender] == 0) removeBalance(msg.sender); 
        return data;
    }

    function getBalance() external view returns(uint256) {
        return balance[msg.sender];
    }

    function getTotalAllocated() external view returns(uint256) {
        /* 
            function to get the total balance of the contract
            funcion para obtener el valor total del contrato 
            funcion para agregar transparencia publica
        */
        return address(this).balance; 
    }

    //FUNCIONES SOLO PARA EL OWNER DEL CONTRATO
    function withdrawAll() external onlyOwner returns(bytes memory) {
        address to = msg.sender;
        uint256 myBalance = balance[msg.sender];
        balance[msg.sender] = 0;
        (bool success, bytes memory data) = to.call{value: myBalance}("");
        if(!success) revert();
        emit onWithdraw(msg.sender, myBalance); //evento para web3
        removeBalance(to); 
        return data;
    }

    function withdrawPartialFromOwner(address _anyAddrress, uint256 _amount) external onlyOwner returns (bytes memory) {
        /* funcion para que el owner pueda retirar una cantidad parcial de un contrato de terceros
           function for the owner to withdraw a partial amount from a third party address
        */
        uint256 amount = _amount;
        uint256 userBalance = balance[_anyAddrress];
        if (amount > userBalance) {
            revert InvalidAmmount("Invalid ammount to withdraw");
        }

        balance[_anyAddrress] = userBalance - amount;

        (bool success, bytes memory data) = payable(_anyAddrress).call{value: amount}("");
        if (!success) {
            revert();
        }
        emit onWithdraw(_anyAddrress, amount); //evento para web3
        if(balance[_anyAddrress] == 0) removeBalance(_anyAddrress);
        return data;
    }

    //FUNCIONES PRIVADAS
    function removeBalance(address _addr) private {
        /*
            pone en 0 el balance de una direccion si es 0
            sets to 0 the balance of an address if it is 0
        */
        if(balance[_addr] == 0){
            delete balance[_addr];
        }
    }

}