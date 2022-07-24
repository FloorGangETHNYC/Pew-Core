// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./Giv3Treasury.sol";

contract Giv3TreasuryFactory {
    uint256 collectionsCounter = 0;

    // Map Id to collection
    mapping(uint256 => Giv3Treasury) treasuries;

    IGiv3Core public GIV3_CORE;

    event TreasuryCreated(uint256 id, string name);

    modifier onlyGiv3() {
        require(msg.sender == address(GIV3_CORE));
        _;
    }

    constructor(IGiv3Core _giv3Core) {
        GIV3_CORE = _giv3Core;
    }

    function createTreasury(string memory name)
        public
        onlyGiv3
        returns (Giv3Treasury)
    {
        Giv3Treasury giv3Treasury = new Giv3Treasury(name, GIV3_CORE);

        treasuries[collectionsCounter] = giv3Treasury;
        collectionsCounter++;

        emit TreasuryCreated(collectionsCounter - 1, name);
        return giv3Treasury;
    }

    function getTreasury(uint256 id) public view returns (Giv3Treasury) {
        return treasuries[id];
    }
}
