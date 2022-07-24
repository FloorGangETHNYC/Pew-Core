// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./Giv3NFTFactory.sol";

contract Giv3Core {
    Giv3NFTFactory public GIV3_NFT_FACTORY;

    struct DAO {
        address contractAddress;
        string detailsHash;
    }

    mapping(uint256 => DAO) public daoIds;

    uint256 public daoCounter;

    event DAOCreated(string name, string symbol, address dao);
    event DAOJoined(address indexed member, uint256 indexed _id);

    constructor() {}

    /**
     * @notice Create a new DAO.
     * @param name The name of the DAO.
     * @param symbol The symbol of the DAO.
     * @param metadataHash Metadata Hash of the DAO
     * @dev Include a offchain signer to verify if the structure of the datafile is correct
     */
    function createDAO(
        string memory name,
        string memory symbol,
        string memory metadataHash
    ) public {
        Giv3NFT giv3NFT = GIV3_NFT_FACTORY.createCollection(name, symbol);

        daoIds[daoCounter] = DAO(address(giv3NFT), metadataHash);
        daoCounter++;
        emit DAOCreated(name, symbol, address(giv3NFT));
    }

    function joinDAO(uint256 _id) public {
        require(
            GIV3_NFT_FACTORY.getCollection(_id).balanceOf(msg.sender) == 0,
            "User already minted"
        );
        GIV3_NFT_FACTORY.getCollection(_id).mint(msg.sender);

        emit DAOJoined(msg.sender, _id);
    }

    function getContract(uint256 _id) public view returns (address) {
        return daoIds[_id].contractAddress;
    }

    function setGiv3NFTFactory(address _giv3NFTFactory) public {
        GIV3_NFT_FACTORY = Giv3NFTFactory(_giv3NFTFactory);
    }

    function getPowerLevels(uint256 _id, uint256 _tokenId)
        public
        view
        returns (uint256)
    {
        return GIV3_NFT_FACTORY.getCollection(_id).getPowerLevel(_tokenId);
    }
}
