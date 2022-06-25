// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "./PewNFT.sol";

contract PewNFTFactory {
    uint256 collectionsCounter = 0;

    // Map Id to collection
    mapping(uint256 => PewNFT) collections;

    address public PEW_CORE;

    event CollectionCreated(uint256 id, address collection);

    constructor(address _pewCore) {
        PEW_CORE = address(_pewCore);
    }

    function createCollection(
        string memory name,
        string memory symbol,
        address _pewCore
    ) public {
        PewNFT pewAddress = new PewNFT(name, symbol, _pewCore);

        collections[collectionsCounter] = pewAddress;
        collectionsCounter++;

        // emit CollectionCreated()
    }

    function getCollection(uint256 id) public view returns (PewNFT) {
        return collections[id];
    }
}
