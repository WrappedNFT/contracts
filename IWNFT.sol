// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.3.2 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

interface IWNFT {
    function positions(uint256 tokenId)
        external
        view
        returns (
            address[] memory tokens,
            string[] memory types,
            uint256[] memory ids,
            uint256[] memory amounts
        );
}