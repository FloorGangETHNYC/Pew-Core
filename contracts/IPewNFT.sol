// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface PewNFT is IERC721 {
    function mint(address _to, uint256 _tokenId) external;

    function totalSupply() external view returns (uint256);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}
