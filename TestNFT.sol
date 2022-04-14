// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./utils/Address.sol";
import "./utils/Context.sol";
import "./utils/Counters.sol";
import "./access/Ownable.sol";
import "./token/ERC721/IERC721.sol";
import "./token/ERC721/ERC721.sol";

contract TestNFT is Context, Ownable, ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
    constructor(string memory name, string memory symbol)
        ERC721(name, symbol)
        Ownable()
    {
        
    }
    
    function mint()
        public
        returns (uint256)
    {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(_msgSender(), newItemId);

        return newItemId;
    }
}