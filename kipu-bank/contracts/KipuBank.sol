/// SPDX-License-Identifier: GNU-GPLv3-only
pragma solidity >=0.8.0; 


/// @title KipuBank - Un banco simple para depósitos y retiros de ETH
/// @author Agustín M.
/// @notice This contract allows users to deposit and withdraw ether with certain limits.
/// @notice Minimum deposit amount: 0.01 ether.
/// @notice Límite máximo de retiro por transacción: definido en el deploy.
/// @dev Incluye funciones especiales del owner que permiten al dueño devolver fondos a usuarios.
contract KipuBank {

    address immutable public owner; /// public para generar transparencia
    uint256 immutable MAXIMUMTOWITHDRAW; /// cantidad maxima para retirar en una sola transaccion
    uint256 immutable BANKCAP; /// cantidad maxima global de depositos en el contrato
    uint256 public constant MINIMUMDEPOSITAMOUNT = 0.01 ether; /// cantidad minima para depositar
    uint256 public totalDeposits; /// variable para llevar el control de los depositos globales
    uint256 public totalWithdraws; /// variable para llevar el control de los retiros globales

    mapping(address=>uint256) public balance; 
    
    error InvalidMinimum();///Invalid minimum deposit
    error NotTheOwner(); /// Not the owner of the contract
    error InvalidAmountToWothdraw(); ///Invalid amount to withdraw
    error ExceededGlobalLimit(); ///Exceded global deposit limit
    error TransferFailed(); /// Transfer failed

    event Deposited(address indexed  payer, uint256 amount); /// event emited on deposit
    event WithDrawn(address indexed withdrawer, uint256 amount); /// event emited on withdraw

    /**
     * @dev Modifier to restrict functions to only the contract owner
     */
    modifier onlyOwner() { 
        if(msg.sender != owner) revert NotTheOwner();
        _;
    }

    /**
     * @dev Modifier to verify that the deposit amount meets the minimum requirement
     */
    modifier VerifyMinimumDeposit() {
        if(msg.value < MINIMUMDEPOSITAMOUNT) revert InvalidMinimum();
        _;
    }

    /// @dev depoist limits are set at deployment
    constructor(uint256 _globalDepositLimit) {
        owner = msg.sender; 
        MAXIMUMTOWITHDRAW = 0.01 ether; 
        BANKCAP = _globalDepositLimit; 
    }

    /**
     * @notice Add ether to your balance, only if the amount is greater 0.1 ether 
     */
    function addAmount() external payable VerifyMinimumDeposit{
        address sender = msg.sender;
        uint256 amount = uint256(msg.value);
        if ((balance[sender] += amount) > BANKCAP) revert ExceededGlobalLimit();
        ++totalDeposits;
        emit Deposited(sender, amount); /// evento para web3
    }

    /** 
    *  @notice Function for the msg.sender to withdraw a partial amount
    */
    function withdrawPartialUsers(uint256 _amount) external returns (bytes memory) {
        /// checks
        uint256 amount = _amount;
        uint256 userBalance = balance[msg.sender];
        
        /// effects
        /// chequeo balance > amount en _substractBalance
        balance[msg.sender] = _substractBalance(userBalance,amount);
        /// prevenido contra reentrancy attack
        ++totalWithdraws;

        /// interaction
        (bool success, bytes memory data) = payable(msg.sender).call{value: amount}("");
        if (!success) revert TransferFailed();

        emit WithDrawn(msg.sender, amount); /// evento para web3
        return data;
    }

     /**
     * @notice returns the balance of the account that is using the contract.
     * @return uint256 = Account balance
     */
    function getBalance() external view returns(uint256) {
        return balance[msg.sender];
    }

     /**
     * @notice returns total number of deposits made by users. Does not consider deposits made by the owner
     * @return uint256 = total deposits made by users
     */
    function getTotalDeposits() external view returns(uint256) {
        return totalDeposits;
    }

    /**
    * @notice Returns total number of withdraws made by users. Does not consider withdrawals made by the owner
    * @return uint256 = total withdraws made by users
    */
    function getTotalWithdraws() external view returns(uint256) {
        return totalWithdraws;
    }

    /**  
    * @notice Function to get the total value of the contract and add public transparency.
    * @return uint256 = total balance of the whole contract
    */
    function getTotalAllocated() external view returns(uint256) {
        return address(this).balance; 
    }

    /**
     * @dev JUST FOR CONTRACT OWNER FUNCTION
     * Function for the owner to withdraw and send all it balance to a third party address
     * @param _anyAddrress = direccion del contrato de terceros
     */
    function withdrawAll(address _anyAddrress) external onlyOwner returns(bytes memory) {
        ///checks
        address to = _anyAddrress;
        uint256 userBalance = balance[_anyAddrress];

        /// effects
        balance[_anyAddrress] = _substractBalance(userBalance, userBalance);
        /// prevenido contra reentrancy attack
        ++totalWithdraws;

        /// interaction
        (bool success, bytes memory data) = to.call{value: userBalance}("");
        if(!success) revert TransferFailed();

        emit WithDrawn(msg.sender, userBalance); /// evento para web3
        return data;
    }

    /**
    * @dev JUST FOR CONTRACT OWNER FUNCTION
    * @notice Function for the owner to withdraw a partial it amount to a third party address
    * @param _anyAddress = third party address
    * @param _amount = amount to be withdrawn
    */
    function withdrawPartialFromOwner(address _anyAddress, uint256 _amount) external onlyOwner returns (bytes memory) {
        ///checks
        uint256 userBalance = balance[_anyAddress];

        /// effects
        /// chequeo balance > amount en _substractBalance
        balance[_anyAddress] = _substractBalance(userBalance, _amount);
        /// prevenido contra reentrancy attack
        ++totalWithdraws;

        /// interactions
        (bool success, bytes memory data) = payable(_anyAddress).call{value: _amount}("");
        if (!success) revert TransferFailed();

        emit WithDrawn(_anyAddress, _amount); //evento para web3
        return data;
    }

    /**
    * @notice Reduce el balance de una direccion en una cantidad determinada
    * @notice Independientemente de que consume un poquito más gas, se decidió crear esta función para separar trabajos.
    * @notice Reduces the balance of an address by a determined amount
    * @notice Regardless of whether more gas is consumed, it was decided to create this function to separate tasks
    * @param _actualBalance = balance before reduction
    * @param _amountToReduce = amount to be reduced from balance
    * @return uint256 = returns updated balance
    * @dev Solo el owner puede retirar más de MAXIMUMTOWITHDRAW
    */
    function _substractBalance(uint256 _actualBalance, uint256 _amountToReduce) private view returns (uint256) {
        if (_actualBalance == 0) revert InvalidAmountToWothdraw();
        if (_amountToReduce > _actualBalance) revert InvalidAmountToWothdraw();
        if (_amountToReduce > MAXIMUMTOWITHDRAW && msg.sender != owner) revert InvalidAmountToWothdraw();
        unchecked {
            return _actualBalance - _amountToReduce;
        }
    }
}