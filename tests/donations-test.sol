pragma solidity ^0.8.0;

contract donations{

    error InvalidateValue();
    error InvalidAmmount();

    mapping (address => uint256) public balance;

    event OnPay(address sender, uint256 ammount);

    function deposit() external payable{
        uint256 ammount = msg.value;
        if(ammount>=3 ether) revert InvalidateValue();
        balance[msg.sender] += ammount;
        emit OnPay(msg.sender, ammount);
    }

    function deposit1(uint256 _ammount) external payable{
        uint256 ammount = _ammount;
        if(ammount>=3 ether) revert InvalidateValue();
        balance[msg.sender] += ammount;
        emit OnPay(msg.sender, ammount);
    }

    function withdraw() external returns(bytes memory){
        address to = msg.sender;
        uint ammount = balance[msg.sender];
        balance[msg.sender] = 0;
        (bool success, bytes memory data) = to.call{value: ammount}("");
        if(!success) revert();
        return data;
    }

    function withdrawParcial(uint256 _ammount) external payable returns(bytes memory){
        address to = msg.sender;
        uint ammount = _ammount;
        if(ammount <= balance[msg.sender]){
            balance[msg.sender] -= _ammount;
            (bool success, bytes memory data) = to.call{value: ammount}("");
            if(!success) revert();
            return data;
        }
        else {
            revert InvalidAmmount();
        }
    }


    function withdrawPartial2(uint256 amount) external returns (bytes memory) {
        uint256 userBalance = balance[msg.sender];
        if (amount > userBalance) {
            revert InvalidAmmount();
        }

        // actualizamos el estado antes de enviar
        balance[msg.sender] = userBalance - amount;

        (bool success, bytes memory data) = payable(msg.sender).call{value: amount}("");
        if (!success) {
            revert("Transfer failed");
        }
        return data;
    }


}