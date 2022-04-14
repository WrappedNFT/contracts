// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./IWNFT.sol";
import "./utils/Address.sol";
import "./token/ERC20/IERC20.sol";
import "./token/ERC20/extensions/IERC20Metadata.sol";
import "./token/ERC20/utils/SafeERC20.sol";
import "./token/ERC721/IERC721.sol";
import "./token/ERC721/extensions/IERC721Metadata.sol";
import "./token/ERC1155/IERC1155.sol";

contract Helpful {
    using SafeERC20 for IERC20;
    using Address for address;

    struct Position {
        address[] tokens;
        string[] types;
        uint256[] ids;
        uint256[] amounts;
    }

    uint256 constant MAX_UINT256 = 2**256 - 1;

    /* Fallback function, don't accept any ETH */
    fallback() external payable {
        revert("Contract does not accept payments");
    }

    receive() external payable {
        revert("Contract does not accept payments");
    }

    function tokenBalance(address user, address token)
        public
        view
        returns (uint256) {
        if (token.isContract()) {
            IERC20 erc20token = IERC20(token);
            try erc20token.balanceOf(user) returns (uint256 balance) {
                return balance;
            } catch {

            }
        }

        return 0;
    }

    function tokenName(address token)
        public
        view
        returns (string memory) {
        if (token.isContract()) {
            IERC20Metadata erc20token = IERC20Metadata(token);
            try erc20token.name() returns (string memory name) {
                return name;
            } catch {

            }
        }

        return '';
    }

    function tokenSymbol(address token)
        public
        view
        returns (string memory) {
        if (token.isContract()) {
            IERC20Metadata erc20token = IERC20Metadata(token);
            try erc20token.symbol() returns (string memory symbol) {
                return symbol;
            } catch {

            }
        }

        return '';
    }

    function tokenDecimal(address token)
        public
        view
        returns (uint8) {
        if (token.isContract()) {
            IERC20Metadata erc20token = IERC20Metadata(token);
            try erc20token.decimals() returns (uint8 decimals) {
                return decimals;
            } catch {

            }
        }

        return 0;
    }

    function tokenBalances(address user, address[] calldata tokens)
        external
        view
        returns (
            uint256[] memory balances
        )
    {
        uint256[] memory addrBalances = new uint256[](tokens.length);
        for (uint256 j = 0; j < tokens.length; j++) {
            if (tokens[j] != address(0x0)) { 
                addrBalances[j] = tokenBalance(user, tokens[j]);
            } else {
                addrBalances[j] = user.balance; // ETH balance    
            }
        }
    
        return addrBalances;
    }

    function tokenNames(address[] calldata tokens)
        external
        view
        returns (
            string[] memory names
        )
    {
        string[] memory addrNames = new string[](tokens.length);
        for (uint j = 0; j < tokens.length; j++) {
            if (tokens[j] != address(0x0)) { 
                addrNames[j] = tokenName(tokens[j]);
            } else {
                addrNames[j] = '';  
            }
        }
    
        return addrNames;
    }

    function tokenSymbols(address[] calldata tokens)
        external
        view
        returns (
            string[] memory symbols
        )
    {
        string[] memory addrSymbols = new string[](tokens.length);
        for (uint j = 0; j < tokens.length; j++) {
            if (tokens[j] != address(0x0)) { 
                addrSymbols[j] = tokenSymbol(tokens[j]);
            } else {
                addrSymbols[j] = '';    
            }
        }
    
        return addrSymbols;
    }

    function tokenDecimals(address[] calldata tokens)
        external
        view
        returns (
            uint8[] memory decimals
        )
    {
        uint8[] memory addrDecimals = new uint8[](tokens.length);
        for (uint j = 0; j < tokens.length; j++) {
            if (tokens[j] != address(0x0)) { 
                addrDecimals[j] = tokenDecimal(tokens[j]);
            } else {
                addrDecimals[j] = 0;
            }
        }
    
        return addrDecimals;
    }

    function token721Name(address token)
        public
        view
        returns (string memory) {
        if (token.isContract()) {
            IERC721Metadata erc721token = IERC721Metadata(token);
            try erc721token.supportsInterface(type(IERC721Metadata).interfaceId) returns (bool erc721MetadataSupports) {
                if (erc721MetadataSupports) {
                    return erc721token.name();
                }
            } catch {

            }
        }

        return '';
    }

    function token721Symbol(address token)
        public
        view
        returns (string memory) {
        if (token.isContract()) {
            IERC721Metadata erc721token = IERC721Metadata(token);
            try erc721token.supportsInterface(type(IERC721Metadata).interfaceId) returns (bool erc721MetadataSupports) {
                if (erc721MetadataSupports) {
                    return erc721token.symbol();
                }
            } catch {

            }
        }

        return '';
    }

    function token721Uri(address token, uint256 tokenId)
        public
        view
        returns (string memory) {
        if (token.isContract()) {
            IERC721Metadata erc721token = IERC721Metadata(token);
            try erc721token.supportsInterface(type(IERC721Metadata).interfaceId) returns (bool erc721MetadataSupports) {
                if (erc721MetadataSupports) {
                    return erc721token.tokenURI(tokenId);
                }
            } catch {

            }
        }

        return '';
    }

    function token721Ownership(address user, address token, uint256[] calldata tokenIds)
        external
        view
        returns (
            bool[] memory tokensOwnership
        )
    {
        if (tokenIds.length == 0) {
            return new bool[](0);
        }

        bool[] memory tokenIdsOwnership = new bool[](tokenIds.length);

        if (token.isContract()) {
            IERC721 erc721token = IERC721(token);
            try erc721token.supportsInterface(type(IERC721).interfaceId) returns (bool erc721Supports) {
                if (erc721Supports) {
                    for (uint256 i = 0; i < tokenIds.length; i++) {
                        try erc721token.ownerOf(tokenIds[i]) returns (address tokenOwner) {
                            if (tokenOwner == user) {
                                tokenIdsOwnership[i] = true;
                            }
                        } catch {

                        }
                    }
                }
            } catch {

            }
        }

        return tokenIdsOwnership;
    }

    function token721Names(address[] calldata tokens)
        external
        view
        returns (
            string[] memory names
        )
    {
        string[] memory addrNames = new string[](tokens.length);
        for (uint j = 0; j < tokens.length; j++) {
            if (tokens[j] != address(0x0)) { 
                addrNames[j] = token721Name(tokens[j]);
            } else {
                addrNames[j] = '';  
            }
        }
    
        return addrNames;
    }

    function token721Symbols(address[] calldata tokens)
        external
        view
        returns (
            string[] memory symbols
        )
    {
        string[] memory addrSymbols = new string[](tokens.length);
        for (uint j = 0; j < tokens.length; j++) {
            if (tokens[j] != address(0x0)) { 
                addrSymbols[j] = token721Symbol(tokens[j]);
            } else {
                addrSymbols[j] = '';    
            }
        }
    
        return addrSymbols;
    }

    function token721Uris(address token, uint256[] calldata tokenIds)
        external
        view
        returns (
            string[] memory uris
        )
    {
        string[] memory addrUris = new string[](tokenIds.length);
        if (token != address(0x0)) {
            for (uint j = 0; j < tokenIds.length; j++) {
                addrUris[j] = token721Uri(token, tokenIds[j]);
            }
        }
    
        return addrUris;
    }

    function token1155Ownership(address user, address token, uint256[] calldata tokenIds)
        external
        view
        returns (
            uint256[] memory tokensOwnership
        )
    {
        if (tokenIds.length == 0) {
            return new uint256[](0);
        }

        uint256[] memory tokenIdsOwnership = new uint256[](tokenIds.length);

        if (token.isContract()) {
            IERC1155 erc1155token = IERC1155(token);
            try erc1155token.supportsInterface(type(IERC1155).interfaceId) returns (bool erc1155Supports) {
                if (erc1155Supports) {
                    for (uint256 i = 0; i < tokenIds.length; i++) {
                        uint256 tokenCount = erc1155token.balanceOf(user, tokenIds[i]);
                        tokenIdsOwnership[i] = tokenCount;
                    }
                }
            } catch {

            }
        }

        return tokenIdsOwnership;
    }

    function wnftPositions(address wnft_token, uint256[] calldata tokenIds)
        external
        view
        returns (
            Position[] memory tokensPositions
        )
    {
        if (tokenIds.length == 0) {
            return new Position[](0);
        }

        Position[] memory tokenIdsPositions = new Position[](tokenIds.length);

        if (wnft_token.isContract()) {
            IWNFT wnftToken = IWNFT(wnft_token);
            for (uint256 i = 0; i < tokenIds.length; i++) {
                try wnftToken.positions(tokenIds[i]) returns (address[] memory tokens,
                    string[] memory types,
                    uint256[] memory ids,
                    uint256[] memory amounts) {
                    tokenIdsPositions[i] = Position({
                        tokens: tokens,
                        types: types,
                        ids: ids,
                        amounts: amounts
                    });
                } catch {

                }
            }
        }

        return tokenIdsPositions;
    }
}