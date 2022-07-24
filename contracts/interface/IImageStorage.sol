// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.10;

interface IImageStorage {
    function getBody() external view returns (string memory);

    function getLayer1(uint256 _index) external view returns (string memory);

    function getLayer2(uint256 _index) external view returns (string memory);

    function getLayer3(uint256 _index) external view returns (string memory);

    function getLayer4(uint256 _index) external view returns (string memory);

    function getLayer5(uint256 _index) external view returns (string memory);

    function getImageForCollection(uint256 collectionIndex, uint256 imageIndex)
        external
        view
        returns (string memory);
}
