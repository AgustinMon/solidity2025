pragma solidity >0.8.0;

contract KipuBank {

    address immutable public owner; //public para generar transparencia
    uint256 private MINIMUMAMOUNT = 0.1 ether;

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
        if (msg.value != MINIMUMAMOUNT) revert InvalidMinimum("You must send exactly 0.1 ether");
        balance[msg.sender] += msg.value;
        emit onPaid(msg.sender, msg.value); //evento para web3
    }

    function withdrawAll() external onlyOwner returns(bytes memory) {
        address to = msg.sender;
        uint256 myBalance = balance[msg.sender];
        balance[msg.sender] = 0;
        (bool success, bytes memory data) = to.call{value: myBalance}("");
        if(!success) revert();
        emit onWithdraw(msg.sender, myBalance); //evento para web3
        return data;
    }

    function withdrawPartial(uint256 _amount) external onlyOwner returns (bytes memory) {
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
        return data;
    }

    function getBalance() external view returns(uint256) {
        return balance[msg.sender];
    }

    function getContractBalance() external view returns(uint256) {
        /* 
            function to get the total balance of the contract
            funcion para obtener el valor total del contrato 
            funcion para agregar transparencia publica
        */
        return address(this).balance; 
    }

}