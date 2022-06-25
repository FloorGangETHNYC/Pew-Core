// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "./PewNFTFactory.sol";

contract PewCore {
    PewNFTFactory public PEW_NFT_FACTORY;

    mapping(uint256 => string) daoIds;

    uint256 daoCounter;

    event DAOCreated(string name, string symbol, address dao);
    event DAOJoined(address indexed member, uint256 indexed _id);

    constructor() {}

    /**
     * @notice Create a new DAO.
     * @param name  name The name of the DAO.
     * @param symbol The symbol of the DAO.
     * @param metadataHash Metadata Hash of the DAO
     * @dev Include a offchain signer to verify if the structure of the datafile is correct
     */
    function createDAO(
        string memory name,
        string memory symbol,
        string memory metadataHash
    ) public {
        PewNFT pewNFT = PEW_NFT_FACTORY.createCollection(
            name,
            symbol,
            address(this)
        );

        daoIds[daoCounter] = metadataHash;
        daoCounter++;

        emit DAOCreated(name, symbol, address(pewNFT));
    }

    function joinDAO(uint256 _id) public {
        PEW_NFT_FACTORY.getCollection(_id).mint(msg.sender);

        emit DAOJoined(msg.sender, _id);
    }

    function addContribution(
        uint256 _id,
        uint256 _tokenId,
        string memory ipfsHash
    ) public {
        require(bytes(ipfsHash).length == 46, "Incorrect Hash Length");
        require(bytes(ipfsHash)[0] == 0x51, "1st char not Q");
        require(bytes(ipfsHash)[1] == 0x6d, "2nd chat not m");

        PEW_NFT_FACTORY.getCollection(_id).addContribution(ipfsHash, _tokenId);
    }

    function upvote(
        uint256 _id,
        uint256 _tokenId,
        uint256 _contributionIndex
    ) public {
        PEW_NFT_FACTORY.getCollection(_id).upvote(_tokenId, _contributionIndex);
    }

    function downvote(
        uint256 _id,
        uint256 _tokenId,
        uint256 _contributionIndex
    ) public {
        PEW_NFT_FACTORY.getCollection(_id).downvote(
            _tokenId,
            _contributionIndex
        );
    }

    function setPewNFTFactory(address _pewNFTFactory) public {
        PEW_NFT_FACTORY = PewNFTFactory(_pewNFTFactory);
    }
}
