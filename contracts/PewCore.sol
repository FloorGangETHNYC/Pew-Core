// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "./PewNFTFactory.sol";

contract PewCore {
    PewNFTFactory public PEW_NFT_FACTORY;

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
        PewNFT pewNFT = PEW_NFT_FACTORY.createCollection(
            name,
            symbol,
            address(this)
        );

        daoIds[daoCounter] = DAO(address(pewNFT), metadataHash);
        daoCounter++;
        emit DAOCreated(name, symbol, address(pewNFT));
    }

    function joinDAO(uint256 _id) public {
        require(
            PEW_NFT_FACTORY.getCollection(_id).balanceOf(msg.sender) == 0,
            "User already minted"
        );
        PEW_NFT_FACTORY.getCollection(_id).mint(msg.sender);

        emit DAOJoined(msg.sender, _id);
    }

    /**
     * @notice Add a contributement statement
     * @param _id Id of the DAO
     * @param _tokenId TokenId of the token
     * @param ipfsHash Metadata Hash of the contribution
     * @dev Include a offchain signer to verify if the structure of the datafile is correct
     */
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

    /**
     * @notice Upvote a contribution
     * @param _id Id of the DAO
     * @param _tokenId TokenId of the token
     * @param _contributionIndex Index of the contribution
     */
    function upvote(
        uint256 _id,
        uint256 _tokenId,
        uint256 _contributionIndex
    ) public {
        PEW_NFT_FACTORY.getCollection(_id).upvote(_tokenId, _contributionIndex);
    }

    /**
     * @notice Downvote a contribution
     * @param _id Id of the DAO
     * @param _tokenId TokenId of the token
     * @param _contributionIndex Index of the contribution
     */
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
