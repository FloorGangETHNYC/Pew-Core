// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IGiv3Core {
    function createDAO(
        string memory name,
        string memory symbol,
        string memory metadataHash
    ) external;

    function joinDAO(uint256 _id) external;

    function getContract(uint256 _id) external view returns (address);

    function setGiv3NFTFactory(address _giv3NFTFactory) external;

    function getPowerLevels(uint256 _id, uint256 _tokenId)
        external
        view
        returns (uint256);
}
