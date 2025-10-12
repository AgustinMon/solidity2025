// SPDX-License-Identifier: MIT
pragma solidity > 0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface IPermissions {
    function hasPermission(address user) external view returns (bool);
}

contract Token is ERC20 {

    error NoPermission(address user);

    IPermissions public permisions;

    constructor(IPermissions Permisions) ERC20("Modulo3", "M3") {
        permisions = Permisions;      
        mint(10000);
    }

    function mint(uint256 amount) private {
        if(!permisions.hasPermission(msg.sender)) revert("No tienes permisos para desplegar este contrato");
        super._mint(msg.sender, amount * (10 ** decimals()));
    }

    function transfer(address to, uint256 value) public override  returns (bool) {
        if (!permisions.hasPermission(to)) revert NoPermission(to);
        return super.transfer(to,value);
    }

    function transferFrom(address from, address to, uint256 value) public override returns (bool) {
        if (!permisions.hasPermission(to)) revert NoPermission(to);
        return super.transferFrom(from,to,value);
    }

    function burn(address from, uint256 amount) public {
        super._burn(from, amount);
    }
}