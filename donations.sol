

Codigo primera parte de la clase:
    // SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

contract KipuBankNotFinished {

    error InvalidValue();
    event paid(address indexed  payer, uint256 amount);

    mapping(address=>uint256) public balance; // no se pueden recorrer
    // key => valor

    address[] public addr;


    function pay() external payable {
        if (msg.value != 0.1 ether) revert InvalidValue();
        balance[msg.sender] += msg.value;
        addr.push(msg.sender);
        emit paid(msg.sender, msg.value);
    }
    
   bool flag;
   modifier reentrancyGuard() {
      if(flag != 0) revert();
      flag = 1;
      _;
      flag = 0;
   }


    function withdraw() external reentrancyGuard returns(bytes memory) {
        address to = msg.sender;
        uint256 miBalance = balance[msg.sender];
        balance[msg.sender] = 0;
        (bool success, bytes memory data) = to.call{value: miBalance}("");
        if(!success) revert();
        return data;
    }

    function withdraw2() external{
        address payable to = payable(msg.sender); // send, transfer
        uint256 miBalance = balance[msg.sender];
        balance[msg.sender] = 0;
        to.transfer(miBalance); // gas = 2300
    }

    function withdraw3() external{
        address payable to = payable(msg.sender); // send, transfer
        uint256 miBalance = balance[msg.sender];
        balance[msg.sender] = 0;
        bool success = to.send(miBalance); // gas = 2300
        if (!success) revert();
    }

}














Donations.sol:
    
    /*
Crea un contrato Solidity llamado `Donations` con las siguientes características:

1. **Variables**:
   - Una variable immutable `beneficiary` (address) para el que puede retirar donaciones.
   - Un mapping `donations` (address => uint256) para rastrear las donaciones por usuario.

2. **Eventos**:
   - Un evento `DonationReceived` que emite la dirección del donante y el monto.
   - Un evento `WithdrawalPerformed` que emite la dirección del receptor y el monto retirado.

3. **Errores**:
   - Un error `TransactionFailed` que recibe un argumento de tipo `bytes`.
   - Un error `UnauthorizedWithdrawer` que recibe dos argumentos de tipo `address`: el llamador y el beneficiario.

4. **Funciones**:
   - Un constructor que recibe una dirección para `beneficiary`.
   - Una función `receive` para aceptar Ether directamente.
   - Una función `donate` que permite a los usuarios donar Ether, actualiza su monto de donación y emite el evento `DonationReceived`.
   - Una función `withdraw` que permite solo al beneficiario retirar un monto específico y emite el evento `WithdrawalPerformed`.
   - Una función privada `_transferEth` que realiza la transferencia de Ether y revierte en caso de fallo.

Asegúrate de que el contrato sea compatible con la versión de Solidity 0.8.26 y de incluir el identificador de licencia SPDX al principio.
*/

// SPDX-License-Identifier: MIT
pragma solidity > 0.8.0;

contract Donations {
   address immutable public BENEFICIARY; // eficiente a nivel de gas
   address constant public BENEFICIARY2 = address(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);
   mapping (address => uint256) public donations;

   event DonationReceived(address sender, uint256 amount);
   event WithdrawalPerformed(address beneficiary, uint256 amount);

   error TransactionFailed(bytes reason);
   error UnauthorizedWithdrawer(address caller, address beneficiary);

   modifier onlyBeneficiary() {
      if (msg.sender != BENEFICIARY) revert UnauthorizedWithdrawer(msg.sender, BENEFICIARY);
      _;
   }

   constructor(address _beneficiary) {
      BENEFICIARY = _beneficiary;
   }

   receive() external payable {
      donations[msg.sender] += msg.value;
      emit DonationReceived(msg.sender, msg.value);
   }

   fallback() external payable {
      donations[msg.sender] += msg.value;
      emit DonationReceived(msg.sender, msg.value);
   }

   function donate() external payable {
      donations[msg.sender] += msg.value;
      emit DonationReceived(msg.sender, msg.value);
   }

   function withdraw() external onlyBeneficiary returns(bytes memory data){
      emit WithdrawalPerformed(BENEFICIARY, address(this).balance); // efect
      data = _transferEth(BENEFICIARY, address(this).balance); // interacion
      return data;
   }

   function _transferEth(address to, uint256 amount) private returns (bytes memory) {
      (bool success, bytes memory data) = to.call{value:amount}("");
      if(!success) revert TransactionFailed("call failed");
      return data;
   }

}