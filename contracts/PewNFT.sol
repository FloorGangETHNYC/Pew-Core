// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

error URIQueryForNonexistentToken();

contract PewNFT is ERC721 {
    using Strings for uint256;

    address public PEW_CORE;
    string public baseURI;

    // The tokenId of the next token to be minted.
    uint128 internal _currentIndex;

    constructor(
        string memory name_,
        string memory symbol_,
        address _pewCore
    ) ERC721(name_, symbol_) {
        PEW_CORE = address(_pewCore);
    }

    modifier onlyPew() {
        require(msg.sender == address(PEW_CORE));
        _;
    }

    function mint(address _to, uint256 _tokenId) external onlyPew {
        _safeMint(_to, _currentIndex);
        _currentIndex++;
    }

    /**
     * Get Total Supply of Tokens Minted
     * @return Current Total Supply
     */
    function totalSupply() public view returns (uint256) {
        return _currentIndex;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     * @dev gets baseURI from contract state variable
     */
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        return
            bytes(baseURI).length != 0
                ? string(abi.encodePacked(baseURI, (tokenId).toString()))
                : "";
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        // Prevent Future Transfer of token
        require(from == address(0), "ERC721: transfer from non-zero address");
    }
}
