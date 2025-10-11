// SPDX-License-Identifier: MIT
pragma solidity > 0.8.0;
import @openzeppelin/contracts/token/ERC20/ERC20.sol;
import @openzeppelin/contracts/access/Ownable.sol;

implementation IPermissions {
    function hasPermission(address user) internal view returns (bool);
}

contract Token is ERC20, Ownable {

    IPermissions public permisions;

    constructor(IPermissions Permisions) ERC20("Modulo3", "M3") {
        permisions = Permisions;      
        mint(address(this), 10000);
    }

    function mint(address to, uint256 amount) private onlyOwner {
        if(!permisions.hasPermission(msg.sender)) revert("No tienes permisos para desplegar este contrato");
        super.mint(msg.sender, amount * (10 ** decimals()));
    }

    function transfer(address to, uint256 value) public override  returns (bool) {
        if (!permisos.hasPermision(to)) revert NoPermission(to);
        return super.transfer(to,value);
    }

    function transferFrom(address from, address to, uint256 value) public override returns (bool) {
        if (!permisos.hasPermision(to)) revert NoPermission(to);
        return super.transferFrom(from,to,value);
    }

    function burn(address from, uint256 amount) public onlyOwner {
        super.burn(from, amount);
    }
}