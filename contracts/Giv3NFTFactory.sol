// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./Giv3NFT.sol";

contract Giv3NFTFactory {
    uint256 collectionsCounter = 0;

    // Map Id to collection
    mapping(uint256 => Giv3NFT) collections;

    IGiv3Core public GIV3_CORE;
    IImageStorage public STATIC_IMAGE_STORAGE;
    IImageStorage public DYNAMIC_IMAGE_STORAGE;

    event CollectionCreated(uint256 id, address collection);

    modifier onlyGiv3() {
        require(msg.sender == address(GIV3_CORE));
        _;
    }

    constructor(
        IGiv3Core _giv3Core,
        IImageStorage _staticImageStorage,
        IImageStorage _dynamicImageStorage
    ) {
        GIV3_CORE = _giv3Core;
        STATIC_IMAGE_STORAGE = _staticImageStorage;
        DYNAMIC_IMAGE_STORAGE = _dynamicImageStorage;
    }

    function createCollection(string memory name, string memory symbol)
        public
        onlyGiv3
        returns (Giv3NFT)
    {
        Giv3NFT giv3Address = new Giv3NFT(
            name,
            symbol,
            GIV3_CORE,
            collectionsCounter,
            STATIC_IMAGE_STORAGE
        );

        collections[collectionsCounter] = giv3Address;
        collectionsCounter++;

        return giv3Address;
        // emit CollectionCreated()
    }

    function getCollection(uint256 id) public view returns (Giv3NFT) {
        return collections[id];
    }
}
