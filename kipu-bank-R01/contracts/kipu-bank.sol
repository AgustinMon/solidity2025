/// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0; /// Solidity 0.8.0+ revierte overflow/underflow automáticamente.


/// @title KipuBank - Un banco simple para depósitos y retiros de ETH
/// @author Agustín M.
/// @notice Este contrato permite a los usuarios depositar y retirar fondos.
/// @notice Depósito mínimo 0.01 ether.
/// @notice Límite máximo de retiro por transacción: definido en el deploy.
/// @dev Incluye funciones especiales del owner que permiten al dueño devolver fondos a usuarios.
contract KipuBank {

    address immutable public owner; /// public para generar transparencia
    uint256 immutable MAXIMUMTOWITHDRAW; /// cantidad maxima para retirar en una sola transaccion
    uint256 immutable BANKCAP; /// cantidad maxima global de depositos en el contrato
    uint256 public constant MINIMUMDEPOSITAMOUNT = 0.01 ether; /// cantidad minima para depositar
    uint256 public totalDeposits = 0; /// variable para llevar el control de los depositos globales
    uint256 public totalWithdraws = 0; /// variable para llevar el control de los retiros globales

    mapping(address=>uint256) public balance; 
    
    error InvalidMinimum();///Invalid minimum deposit
    error NotTheOwner(); /// Not the owner of the contract
    error InvalidAmountToWothdraw(); ///Invalid amount to withdraw
    error ExceededGlobalLimit(); ///Exceded global deposit limit
    error TransferFailed(); /// Transfer failed

    event Deposited(address indexed  payer, uint256 amount);
    event WithDrawn(address indexed withdrawer, uint256 amount);

    modifier onlyOwner() {
        if(msg.sender != owner) revert NotTheOwner();
        _;
    }

    modifier VerifyMinimumDeposit() {
        if(msg.value < MINIMUMDEPOSITAMOUNT) revert InvalidMinimum();
        _;
    }

    /// @dev depoistis limits are set at deployment
    constructor(uint256 _globalDepositLimit) {
        owner = msg.sender; 
        MAXIMUMTOWITHDRAW = 0.01 ether; 
        BANKCAP = _globalDepositLimit; 
    }

    /**
     * @notice Add ether to your balance, only if the amount is greater 0.1 ether 
     * @notice Agrega dinero a tu balance, solo si la cantidad es mayor a 0.1 ether
     */
    function addAmount() external payable VerifyMinimumDeposit{
        address sender = msg.sender;
        if ((balance[sender] += msg.value) > BANKCAP) revert ExceededGlobalLimit();
        ++totalDeposits;
        emit Deposited(sender, msg.value); /// evento para web3
    }

    /** 
    *  @notice Funcion para que el msg.sender pueda retirar una cantidad parcial
    *  @notice Function for the msg.sender to withdraw a partial amount
    */
    function withdrawPartialUsers(uint256 _amount) external returns (bytes memory) {
        uint256 amount = _amount;
        uint256 userBalance = balance[msg.sender];
        /// chequeo balance > amount en _substractBalance
        balance[msg.sender] = _substractBalance(userBalance,amount);
        /// prevenido contra reentrancy attack
        (bool success, bytes memory data) = payable(msg.sender).call{value: amount}("");
        if (!success) {
            revert TransferFailed();
        }
        ++totalWithdraws;
        emit WithDrawn(msg.sender, amount); /// evento para web3
        return data;
    }

     /**
     * @notice retorna el balance de la cuenta que està usando el contrato.
     * @notice returns the balance of the account that is using the contract.
     * @return uint256 = balance de la cuenta
     */
    function getBalance() external view returns(uint256) {
        return balance[msg.sender];
    }

     /**
     * @notice retorna cantidad total de depositos realizados por usuarios. No considera los depositos realizados por el owner.
     * @notice returns total number of deposits made by users. Does not consider deposits made by the owner
     */
    function getTotalDeposits() external view returns(uint256) {
        return totalDeposits;
    }

    /**
    * @notice Retorna cantidad total de retiros realizados por usuarios. No considera los retiros realizados por el owner
    * Returns total number of withdraws made by users. Does not consider withdrawals made by the owner
    */
    function getTotalWithdraws() external view returns(uint256) {
        
        return totalWithdraws;
    }

    /**  
    * @notice Funcion para obtener el valor total del contrato y agregar transparencia publica.
    * @notice Function to get the total value of the contract and add public transparency.
    */
    function getTotalAllocated() external view returns(uint256) {
        return address(this).balance; 
    }

    /**
     * @dev FUNCIONES SOLO PARA EL OWNER DEL CONTRATO
     * Funcion para que el owner pueda devolver todo el balance de un contrato de terceros
     * Function for the owner to withdraw and send all it balance to a third party address
     * @param _anyAddrress = direccion del contrato de terceros
     */
    function withdrawAll(address _anyAddrress) external onlyOwner returns(bytes memory) {
        address to = _anyAddrress;
        uint256 userBalance = balance[_anyAddrress];
        balance[_anyAddrress] = _substractBalance(userBalance, userBalance);
        /// prevenido contra reentrancy attack
        (bool success, bytes memory data) = to.call{value: userBalance}("");
        if(!success) revert();
        ++totalWithdraws;
        emit WithDrawn(msg.sender, userBalance); /// evento para web3
        return data;
    }

    /**
    * @dev FUNCIONES SOLO PARA EL OWNER DEL CONTRATO
    * @notice Funcion para que el owner pueda devolver una cantidad parcial de un contrato a terceros
    * @notice Function for the owner to withdraw a partial it amount to a third party address
    * @param _anyAddress = direccion del contrato de terceros
    * @param _amount = cantidad a retirar
    */
    function withdrawPartialFromOwner(address _anyAddress, uint256 _amount) external onlyOwner returns (bytes memory) {
        uint256 userBalance = balance[_anyAddress];
        /// chequeo balance > amount en _substractBalance
        balance[_anyAddress] = _substractBalance(userBalance, _amount);
        /// prevenido contra reentrancy attack
        (bool success, bytes memory data) = payable(_anyAddress).call{value: _amount}("");
        if (!success) {
            revert();
        }
        ++totalWithdraws;
        emit WithDrawn(_anyAddress, _amount); //evento para web3
        return data;
    }

    /**
    * @notice Reduce el balanace de una direccion en una cantidad determinada
    * @notice Independientemente de que consume un poquito más gas, se decidió crear esta función para separar trabajos.
    * @notice Reduces the balance of an address by a determined amount
    * @notice Regardless of whether more gas is consumed, it was decided to create this function to separate tasks
    * @param _actualBalance = balance actual de la direccion
    * @param _amountToReduce = cantidad a reducir
    * @return uint256 = retorna el balance actualizado
    * @dev Solo el owner puede retirar más de MAXIMUMTOWITHDRAW
    */
    function _substractBalance(uint256 _actualBalance, uint256 _amountToReduce) private view returns (uint256) {
        if (_actualBalance == 0) revert InvalidAmountToWothdraw();
        if (_amountToReduce > _actualBalance) revert InvalidAmountToWothdraw();
        if (_amountToReduce > MAXIMUMTOWITHDRAW && msg.sender != owner) revert InvalidAmountToWothdraw();
        return unchecked {
            _actualBalance - _amountToReduce
        };
    }
}