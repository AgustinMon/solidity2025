// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface IPermission {
    function hasPermission(address user) external view returns (bool);
}

contract Token is ERC20 {
    IPermission public myPermission;
    address public immutable icoContract;

    constructor(IPermission permissions, address _ico) ERC20("Modulo3", "M3") {
        myPermission = permissions;
        icoContract = _ico;
        _mintInitial();
    }

    // 🔐 Solo se ejecuta al desplegar (desde el deployer)
    function _mintInitial() private {
        if (!myPermission.hasPermission(msg.sender))
            revert("User has not permission to mint in this contract");
        _mint(msg.sender, 10000 * (10 ** decimals()));
    }

    // ✅ Aprobar a un contrato o cuenta a gastar tokens
    function approve(address spender, uint256 value) public override returns (bool) {
        if (!myPermission.hasPermission(msg.sender))
            revert("User has not permission to approve in this contract");
        _approve(msg.sender, spender, value);
        return true;
    }

    // ✅ Transferir directamente (solo usuarios permitidos)
    function transfer(address to, uint256 value) public override returns (bool) {
        if (!myPermission.hasPermission(msg.sender))
            revert("User has not permission to transfer in this contract");
        _transfer(msg.sender, to, value);
        return true;
    }

    // ✅ Transferir tokens en nombre de otro (para ICO u otros contratos)
    function transferFrom(address from, address to, uint256 value) public override returns (bool) {
        // Permitimos al contrato ICO o a usuarios con permiso
        if (msg.sender != icoContract && !myPermission.hasPermission(msg.sender)) {
            revert("User has not permission to transferFrom in this contract");
        }

        _spendAllowance(from, msg.sender, value);
        _transfer(from, to, value);
        return true;
    }
}
