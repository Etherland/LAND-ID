pragma solidity 0.6.2;

import "./ERC721.sol";
import "./Interfaces/IERC721Full.sol";

/**
* @title Full ERC721 Token
* This implementation includes all the required and some optional functionality of the ERC721 standard
* Moreover, it includes approve all functionality using operator terminology
* @dev see https://eips.ethereum.org/EIPS/eip-721
* @dev source : openzeppelin-solidity/contracts/token/ERC721/ERC721Full.sol
*/
contract ERC721Full is ERC721, IERC721Full {
    using SafeMath for uint256;

    // // Token name
    // string private _name;

    // // Token symbol
    // string private _symbol;

    // // Optional mapping for token URIs
    // mapping(uint256 => string) private _tokenURIs;

    // using SafeMath for uint256;
    // // Mapping from owner to list of owned token IDs
    // mapping(address => uint256[]) private _ownedTokens;

    // // Mapping from token ID to index of the owner tokens list
    // mapping(uint256 => uint256) private _ownedTokensIndex;

    // // Array with all token ids, used for enumeration
    // uint256[] private _allTokens;

    // // Mapping from token id to position in the allTokens array
    // mapping(uint256 => uint256) private _allTokensIndex;

    // bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;
    // /*
    // * 0x780e9d63 ===
    // *     bytes4(keccak256('totalSupply()')) ^
    // *     bytes4(keccak256('tokenOfOwnerByIndex(address,uint256)')) ^
    // *     bytes4(keccak256('tokenByIndex(uint256)'))
    // */

    // bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;
    // /*
    // * 0x5b5e139f ===
    // *     bytes4(keccak256('name()')) ^
    // *     bytes4(keccak256('symbol()')) ^
    // *     bytes4(keccak256('tokenURI(uint256)'))
    // */


    /**
    * @dev Constructor function
    */
    function init (string memory name, string memory symbol) internal {
        _name = name;
        _symbol = symbol;

        // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
        // register the supported interface to conform to ERC721Enumerable via ERC165
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    /**
    * @dev Gets the token name
    * @return string representing the token name
    */
    function name() external override view returns (string memory) {
        return _name;
    }

    /**
    * @dev Gets the token symbol
    * @return string representing the token symbol
    */
    function symbol() external override view returns (string memory) {
        return _symbol;
    }

    /**
    * @dev Gets the token ID at a given index of the tokens list of the requested owner
    * @param owner address owning the tokens list to be accessed
    * @param index uint256 representing the index to be accessed of the requested tokens list
    * @return uint256 token ID at the given index of the tokens list owned by the requested address
    */
    function tokenOfOwnerByIndex(address owner, uint256 index) public override view returns (uint256) {
        require(index < balanceOf(owner), "index is too high");
        return _ownedTokens[owner][index];
    }

    /**
    * @dev Gets the total amount of tokens stored by the contract
    * @return uint256 representing the total amount of tokens
    */
    function totalSupply() public override view returns (uint256) {
        return _allTokens.length;
    }

    /**
    * @dev Gets the token ID at a given index of all the tokens in this contract
    * Reverts if the index is greater or equal to the total number of tokens
    * @param index uint256 representing the index to be accessed of the tokens list
    * @return uint256 token ID at the given index of the tokens list
    */
    function tokenByIndex(uint256 index) public override view returns (uint256) {
        require(index < totalSupply(), "index is too high");
        return _allTokens[index];
    }

    /**
    * @dev Internal function to transfer ownership of a given token ID to another address.
    * As opposed to transferFrom, this imposes no restrictions on msg.sender.
    * @param from current owner of the token
    * @param to address to receive the ownership of the given token ID
    * @param tokenId uint256 ID of the token to be transferred
    */
    function _transferFrom(address from, address to, uint256 tokenId) internal override {
        super._transferFrom(from, to, tokenId);

        _removeTokenFromOwnerEnumeration(from, tokenId);

        _addTokenToOwnerEnumeration(to, tokenId);
    }

    /**
    * @dev Internal function to mint a new token
    * Reverts if the given token ID already exists
    * @param to address the beneficiary that will own the minted token
    * @param tokenId uint256 ID of the token to be minted
    */
    function _mint(address to, uint256 tokenId) internal override {
        super._mint(to, tokenId);

        _addTokenToOwnerEnumeration(to, tokenId);

        _addTokenToAllTokensEnumeration(tokenId);
    }

    /**
    * @dev Internal function to burn a specific token
    * Reverts if the token does not exist
    * Deprecated, use _burn(uint256) instead
    * @param owner owner of the token to burn
    * @param tokenId uint256 ID of the token being burned
    */
    function _burn(address owner, uint256 tokenId) internal override {
        super._burn(owner, tokenId);

        _removeTokenFromOwnerEnumeration(owner, tokenId);
        // Since tokenId will be deleted, we can clear its slot in _ownedTokensIndex to trigger a gas refund
        _ownedTokensIndex[tokenId] = 0;

        _removeTokenFromAllTokensEnumeration(tokenId);

    }

    /**
    * @dev Gets the list of token IDs of the requested owner
    * @param owner address owning the tokens
    * @return uint256[] List of token IDs owned by the requested address
    */
    function _tokensOfOwner(address owner) internal view returns (uint256[] storage) {
        return _ownedTokens[owner];
    }

    /**
    * @dev Private function to add a token to this extension's ownership-tracking data structures.
    * @param to address representing the new owner of the given token ID
    * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
    */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        _ownedTokensIndex[tokenId] = _ownedTokens[to].length;
        _ownedTokens[to].push(tokenId);
    }

    /**
    * @dev Private function to add a token to this extension's token tracking data structures.
    * @param tokenId uint256 ID of the token to be added to the tokens list
    */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
    * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
    * while the token is not assigned a new owner, the _ownedTokensIndex mapping is _not_ updated: this allows for
    * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
    * This has O(1) time complexity, but alters the order of the _ownedTokens array.
    * @param from address representing the previous owner of the given token ID
    * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
    */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _ownedTokens[from].length.sub(1);
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        _ownedTokens[from].pop();

        // Note that _ownedTokensIndex[tokenId] hasn't been cleared: it still points to the old slot (now occupied by
        // lastTokenId, or just over the end of the array if the token was the last one).
    }

    /**
    * @dev Private function to remove a token from this extension's token tracking data structures.
    * This has O(1) time complexity, but alters the order of the _allTokens array.
    * @param tokenId uint256 ID of the token to be removed from the tokens list
    */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length.sub(1);
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        _allTokens.pop();
        _allTokensIndex[tokenId] = 0;
    }

    /**
     * @dev
     * @notice Non-Standard method to retrieve all NFTs that specific owner owns
     * @return uint[] containing all NFTs that owner owns
     */
    function tokensOf(address owner) public view returns (uint[] memory) {
        return _tokensOfOwner(owner);
    }
}