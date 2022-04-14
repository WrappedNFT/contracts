// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./utils/Address.sol";
import "./utils/Context.sol";
import "./access/Ownable.sol";
import "./token/ERC20/ERC20.sol";

contract TestToken is Context, Ownable, ERC20 {
    constructor(string memory name, string memory symbol)
        ERC20(name, symbol)
        Ownable()
    {
        
    }
    
    function mint(uint256 supply)
        public
    {
        _mint(_msgSender(), supply);
    }
}