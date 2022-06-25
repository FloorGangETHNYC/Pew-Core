// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import {ByteHasher} from "./helpers/ByteHasher.sol";
import {IWorldID} from "./interfaces/IWorldID.sol";

import "./PewNFTFactory.sol";

contract PewCore {
    using ByteHasher for bytes;

    PewNFTFactory public PEW_NFT_FACTORY;

    struct DAO {
        address contractAddress;
        string detailsHash;
    }

    mapping(uint256 => DAO) public daoIds;

    uint256 public daoCounter;

    event DAOCreated(string name, string symbol, address dao);
    event DAOJoined(address indexed member, uint256 indexed _id);

    ///////////////////////////////////////////////////////////////////////////////
    ///                                  ERRORS                                ///
    //////////////////////////////////////////////////////////////////////////////

    /// @notice Thrown when attempting to reuse a nullifier
    error InvalidNullifier();

    /// @dev The WorldID instance that will be used for verifying proofs
    IWorldID internal immutable worldId;

    /// @dev The WorldID group ID (1)
    uint256 internal immutable groupId = 1;

    /// @dev Whether a nullifier hash has been used already. Used to prevent double-signaling
    mapping(uint256 => bool) internal nullifierHashes;

    /// @param input User's input, used as the signal. Could be something else! (see README)
    /// @param root The of the Merkle tree, returned by the SDK.
    /// @param nullifierHash The nullifier for this proof, preventing double signaling, returned by the SDK.
    /// @param proof The zero knowledge proof that demostrates the claimer is registered with World ID, returned by the SDK.
    /// @dev Feel free to rename this method however you want! We've used `claim`, `verify` or `execute` in the past.
    modifier verifyAndExecute(
        address input,
        uint256 root,
        uint256 nullifierHash,
        uint256[8] calldata proof
    ) public {
        // first, we make sure this person hasn't done this before
        if (nullifierHashes[nullifierHash]) revert InvalidNullifier();

        // then, we verify they're registered with WorldID, and the input they've provided is correct
        worldId.verifyProof(
            root,
            groupId,
            abi.encodePacked(input).hashToField(),
            nullifierHash,
            abi.encodePacked(address(this)).hashToField(),
            proof
        );

        // finally, we record they've done this, so they can't do it again (proof of uniqueness)
        nullifierHashes[nullifierHash] = true;

        // your logic here, make sure to emit some kind of event afterwards!
        _;
    }

    /// @param _worldId The WorldID instance that will verify the proofs
    constructor(IWorldID _worldId) {
        worldId = _worldId;
    }

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
    ) public verifyAndExecute() {
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

    function getContract(uint256 _id) public view returns (address) {
        return daoIds[_id].contractAddress;
    }

    function setPewNFTFactory(address _pewNFTFactory) public {
        PEW_NFT_FACTORY = PewNFTFactory(_pewNFTFactory);
    }
}
