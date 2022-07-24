// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./interface/IImageStorage.sol";
import "./interface/IGiv3Core.sol";
import "./Giv3NFTFactory.sol";
import "./Giv3TreasuryFactory.sol";
import "./Giv3AvatarNFT.sol";

contract Giv3Core is IGiv3Core {
    Giv3NFTFactory public GIV3_NFT_FACTORY;
    Giv3TreasuryFactory public GIV3_TREASURY_FACTORY;
    Giv3AvatarNFT public GIV3_AVATAR_NFT;

    struct DAO {
        address contractAddress;
        string description;
    }

    mapping(uint256 => DAO) public daoIds;
    mapping(uint256 => address) public treasuryIds;

    uint256 public daoCounter;

    event DAOCreated(string name, string symbol, address dao);
    event DAOJoined(address indexed member, uint256 indexed _id);

    constructor(
        IImageStorage staticImageStorage,
        IImageStorage dynamicImageStorage
    ) {
        GIV3_NFT_FACTORY = new Giv3NFTFactory(
            IGiv3Core(address(this)),
            staticImageStorage,
            dynamicImageStorage
        );

        GIV3_TREASURY_FACTORY = new Giv3TreasuryFactory(
            IGiv3Core(address(this))
        );

        GIV3_AVATAR_NFT = new Giv3AvatarNFT(
            "GIV3 Avatar",
            "GIV3NFT",
            IGiv3Core(address(this))
        );
    }

    /**
     * @notice Create a new DAO.
     * @param name The name of the DAO.
     * @param symbol The symbol of the DAO.
     * @param description Description of the DAO
     * @dev Include a offchain signer to verify if the structure of the datafile is correct
     */
    function createDAO(
        string memory name,
        string memory symbol,
        string memory description
    ) public {
        Giv3NFT giv3NFT = GIV3_NFT_FACTORY.createCollection(name, symbol);
        Giv3Treasury giv3Treasury = GIV3_TREASURY_FACTORY.createTreasury(name);

        // Mint GIV3Avatar NFT for user if not already exists
        if (GIV3_AVATAR_NFT.balanceOf(msg.sender) == 0) {
            GIV3_AVATAR_NFT.mint(msg.sender);
        }

        daoIds[daoCounter] = DAO(address(giv3NFT), description);
        treasuryIds[daoCounter] = address(giv3Treasury);
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

    function donate(uint256 daoId, uint256 _donationAmount) public {
        // Transfer USDT to sub-DAO Treasury
        GIV3_TREASURY_FACTORY.getTreasury(treasuryIds[daoId]).transfer(
            msg.sender,
            _donationAmount
        );

        // Update Donated amount onto user's subDAO NFT
        GIV3_NFT_FACTORY.getCollection(daoId).addDonation(
            msg.sender,
            _donationAmount
        );
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
