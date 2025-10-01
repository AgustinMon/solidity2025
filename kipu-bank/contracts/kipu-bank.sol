//SPDX-License-Identifier: UNLICENSED
pragma solidity >0.8.0;


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
        if(msg.sender != owner) revert Unauthorized("You are not the owner of the contract.");
        _;
    }

    constructor() {
        owner = msg.sender; //el valor de owner queda determinado en el deploy
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
        /* 
        funcion para que el msg.sender pueda retirar una cantidad parcial
        function for the msg.sender to withdraw a partial amount
        */
        uint256 amount = _amount;
        uint256 userBalance = balance[msg.sender];
        if (amount > userBalance) {
            revert InvalidAmmount("Invalid ammount to withdraw");
        }

        balance[msg.sender] = _removeBalance(userBalance,amount);

        (bool success, bytes memory data) = payable(msg.sender).call{value: amount}("");
        if (!success) {
            revert();
        }
        emit onWithdraw(msg.sender, amount); //evento para web3
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
    function withdrawAll(address _anyAddrress) external onlyOwner returns(bytes memory) {
        /* 
            Funcion para que el owner pueda retirar todo el balance de un contrato de terceros
            Function for the owner to withdraw all the balance from a third party address
            arguments: _anyAddrress = direccion del contrato de terceros
        */
        address to = _anyAddrress;
        uint256 userBalance =_removeBalance(balance[_anyAddrress],balance[_anyAddrress]);
        (bool success, bytes memory data) = to.call{value: userBalance}("");
        if(!success) revert();
        emit onWithdraw(msg.sender, userBalance); //evento para web3
        return data;
    }

    function withdrawPartialFromOwner(address _anyAddress, uint256 _amount) external onlyOwner returns (bytes memory) {
        /* 
            Funcion para que el owner pueda retirar una cantidad parcial de un contrato de terceros
            Function for the owner to withdraw a partial amount from a third party address
            arguments: _anyAddress = direccion del contrato de terceros
                       _amount = cantidad a retirar
        */
        uint256 amount = _amount;
        uint256 userBalance = _removeBalance(balance[_anyAddress],balance[_anyAddress]);
        if (amount > userBalance) {
            revert InvalidAmmount("Invalid ammount to withdraw");
        }

        balance[_anyAddress] = _removeBalance(userBalance, amount);

        (bool success, bytes memory data) = payable(_anyAddress).call{value: amount}("");
        if (!success) {
            revert();
        }
        emit onWithdraw(_anyAddress, amount); //evento para web3
        return data;
    }

    //FUNCIONES PRIVADAS
    function _removeBalance(uint256 _actualBalance, uint256 _amountToReduce) private pure returns (uint256) {
        /*
            Reduce el balanace de una direccion en una cantidad determinada
            Independientemente de si consume más gas, se decidió crear esta función para separar trabajos.
            Reduces the balance of an address by a determined amount
            Regardless of whether it consumes more gas, it was decided to create this function to separate tasks
            arguments: _actualBalance = balance actual de la direccion
                       _amountToReduce = cantidad a reducir
        */
        return _actualBalance - _amountToReduce;
    }

}