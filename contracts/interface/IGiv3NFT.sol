// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IGiv3NFT is IERC721 {
    function mint(address _to, uint256 _tokenId) external;

    function totalSupply() external view returns (uint256);

    function tokenURI(uint256 tokenId) external view returns (string memory);

    function upvote(uint256 tokenId, uint256 contributionIndex)
        external
        view
        returns (string memory);

    function downvote(uint256 tokenId, uint256 contributionIndex)
        external
        view
        returns (string memory);

    function getPowerLevel(uint256 tokenId) external view returns (uint256);
}
