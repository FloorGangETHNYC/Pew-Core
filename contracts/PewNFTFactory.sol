// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "./PewNFT.sol";
import "./IPewNFT.sol";

contract PewNFTFactory {

    uint256 collectionsCounter = 0;

    // Map Id to collection
    mapping(uint256 => address) collections;

    address public PEW_CORE;

    event CollectionCreated(uint256 id, address collection);

    constructor(address _pewCore) public {
        PEW_CORE = address(_pewCore);
    }

    function createCollection(
        string memory name,
        string memory symbol,
        address _pewCore
    ) public returns (address) {
        address pewAddress = new PewNFT(name, symbol, _pewCore).address;

        collections[collectionsCounter] = pewAddress;
        collectionsCounter++;

        emit CollectionCreated()

    }

    function getCollection(uint256 id) public view returns (IPewNFT) {
        return collections[id];
    }
}
