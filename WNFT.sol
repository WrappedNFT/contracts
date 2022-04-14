// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./IWNFT.sol";
import "./utils/Address.sol";
import "./utils/Context.sol";
import "./utils/math/SafeMath.sol";
import "./access/Ownable.sol";
import "./token/ERC721/IERC721.sol";
import "./token/ERC721/ERC721.sol";
import "./token/ERC721/utils/ERC721Holder.sol";
import "./token/ERC1155/IERC1155.sol";
import "./token/ERC1155/utils/ERC1155Receiver.sol";
import "./token/ERC1155/utils/ERC1155Holder.sol";
import "./token/ERC20/IERC20.sol";
import "./token/ERC20/utils/SafeERC20.sol";

contract WNFT is IWNFT, Context, Ownable, ERC721, ERC721Holder, ERC1155Holder {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;
    
    struct Position {
        address[] tokens;
        string[] types;
        uint256[] ids;
        uint256[] amounts;
    }
    
    mapping(uint256 => Position) private _positions;
    
    uint256 private _nextId = 1;
    
    uint256 private _mintFee = 0;
    uint256 private _burnFee = 0;
    
    constructor(string memory name, string memory symbol)
        ERC721(name, symbol)
        Ownable()
    {
        
    }
    
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC1155Receiver) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
    
    function positions(uint256 tokenId)
        external
        view
        virtual
        override
        returns (
            address[] memory tokens,
            string[] memory types,
            uint256[] memory ids,
            uint256[] memory amounts
        )
    {
        Position memory position = _positions[tokenId];
        require(position.tokens.length != 0, 'Invalid token ID');
        return (
            position.tokens,
            position.types,
            position.ids,
            position.amounts
        );
    }
    
    function mint(address[] calldata tokens, uint256[] calldata amounts, uint256[] calldata ids)
        external
        payable
        returns (
            uint256 tokenId
        )
    {
        require(tokens.length > 0, "You are not provide any token");
        require(tokens.length == amounts.length, "Array lengths must be equal");
        require(tokens.length == ids.length, "Array lengths must be equal");
        
        if (_mintFee > 0) {
            require(msg.value >= _mintFee, "You need to pay fee for mint operation");
        }
        
        string[] memory types = new string[](tokens.length);
        for(uint i = 0; i < tokens.length; i++) {
            require(tokens[i] != address(0), "Can't use zero address");
            
            if (tokens[i].isContract()) {
                IERC721 token721 = IERC721(tokens[i]);
                try token721.getApproved(ids[i]) returns (address token721ApprovedOperator) {
                    if (token721ApprovedOperator == address(this)) {
                        token721.safeTransferFrom(_msgSender(), address(this), ids[i]);
                    } else {
                        try token721.isApprovedForAll(_msgSender(), address(this)) returns (bool token721IsApprovedForAll) {
                            require(token721IsApprovedForAll == true, "You did not allow contract to spend your erc721 token (approve or setApprovalForAll)");
                            
                            token721.safeTransferFrom(_msgSender(), address(this), ids[i]);
                        } catch {
                            revert("You did not allow contract to spend your erc721 token (approve)");
                        }
                    }
                    types[i] = "ERC721";
                } catch {
                    IERC1155 token1155 = IERC1155(tokens[i]);
                    try token1155.isApprovedForAll(_msgSender(), address(this)) returns (bool token1155IsApprovedForAll) {
                        require(token1155IsApprovedForAll == true, "You did not allow contract to spend your erc1155 token (setApprovalForAll)");
                        
                        uint256 token1155Balance = token1155.balanceOf(_msgSender(), ids[i]);
                        require(token1155Balance >= amounts[i], "You have not enough token balance");
                        
                        token1155.safeTransferFrom(_msgSender(), address(this), ids[i], amounts[i], "");
                        
                        types[i] = "ERC1155";
                    } catch {
                        IERC20 token = IERC20(tokens[i]);
                        uint256 tokenBalance = token.balanceOf(_msgSender());
                        require(tokenBalance >= amounts[i], "You have not enough token balance");
                        uint256 tokenAllowance = token.allowance(_msgSender(), address(this));
                        require(tokenAllowance >= amounts[i], "You did not allow contract to spend your token (approve)");
                        
                        token.safeTransferFrom(_msgSender(), address(this), amounts[i]);
                        
                        types[i] = "ERC20";
                    }
                }
            } else {
                revert("You must provide only token contracts");
            }
        }
        
        _safeMint(_msgSender(), (tokenId = _nextId++));
        
        _positions[tokenId] = Position({
            tokens: tokens,
            types: types,
            ids: ids,
            amounts: amounts
        });
        
        if (_mintFee > 0) {
            Address.sendValue(payable(owner()), _mintFee);
        }
        
        if (msg.value > _mintFee) {
            uint256 feeChange = msg.value.sub(_mintFee);
            Address.sendValue(payable(_msgSender()), feeChange);
        }
        
        return (
            tokenId
        );
    }
    
    function burn(uint256 tokenId) external payable {
        Position memory position = _positions[tokenId];
        require(position.tokens.length != 0, 'Invalid token ID');
        require(ERC721.ownerOf(tokenId) == _msgSender(), "ERC721: burn of token that is not own");
        
        if (_burnFee > 0) {
            require(msg.value >= _burnFee, "You need to pay fee for burn operation");
        }
        
        delete _positions[tokenId];
        _burn(tokenId);
        
        for(uint i = 0; i < position.tokens.length; i++) {
            if (keccak256(bytes(position.types[i])) == keccak256(bytes("ERC721"))) {
                IERC721 token721 = IERC721(position.tokens[i]);
                token721.safeTransferFrom(address(this), _msgSender(), position.ids[i]);
            } else if (keccak256(bytes(position.types[i])) == keccak256(bytes("ERC1155"))) {
                IERC1155 token1155 = IERC1155(position.tokens[i]);
                token1155.safeTransferFrom(address(this), _msgSender(), position.ids[i], position.amounts[i], "");
            } else {
                IERC20 token = IERC20(position.tokens[i]);
                token.safeTransfer(_msgSender(), position.amounts[i]);
            }
        }
        
        if (_burnFee > 0) {
            Address.sendValue(payable(owner()), _burnFee);
        }
        
        if (msg.value > _burnFee) {
            uint256 feeChange = msg.value.sub(_burnFee);
            Address.sendValue(payable(_msgSender()), feeChange);
        }
    }
    
    function setFee(uint256 mintFee_, uint256 burnFee_)
        external
        payable
        onlyOwner()
        returns (
            uint256 mintFee,
            uint256 burnFee
        )
    {
        _mintFee = mintFee_;
        _burnFee = burnFee_;
        return (
            _mintFee,
            _burnFee
        );
    }
    
    function getFee()
        external
        view
        returns (
            uint256 mintFee,
            uint256 burnFee
        )
    {
        return (
            _mintFee,
            _burnFee
        );
    }
}