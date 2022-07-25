// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./interface/IImageStorage.sol";
import "./interface/IGiv3Core.sol";
import "./Giv3NFTFactory.sol";
import "./Giv3TreasuryFactory.sol";
import "./Giv3AvatarNFT.sol";

// import ownable from openzeppelin
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Giv3Core is IGiv3Core, Ownable {
    Giv3NFTFactory public GIV3_NFT_FACTORY;
    Giv3TreasuryFactory public GIV3_TREASURY_FACTORY;
    Giv3AvatarNFT public GIV3_AVATAR_NFT;
    IERC20 public USDT;

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
        IImageStorage dynamicImageStorage,
        IERC20 _usdt
    ) {
        USDT = _usdt;
    }

    function setGiv3NFTFactory(Giv3NFTFactory _giv3NFTFactory)
        public
        onlyOwner
    {
        GIV3_NFT_FACTORY = _giv3NFTFactory;
    }

    function setGiv3TreasuryFactory(Giv3TreasuryFactory _giv3TreasuryFactory)
        public
        onlyOwner
    {
        GIV3_TREASURY_FACTORY = _giv3TreasuryFactory;
    }

    function setGiv3AvatarNFT(Giv3AvatarNFT _giv3AvatarNFT) public onlyOwner {
        GIV3_AVATAR_NFT = _giv3AvatarNFT;
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

        // Mint GIV3Avatar NFT for user if not already exists
        if (GIV3_AVATAR_NFT.balanceOf(msg.sender) == 0) {
            GIV3_AVATAR_NFT.mint(msg.sender);
        }

        GIV3_NFT_FACTORY.getCollection(_id).mint(msg.sender);

        emit DAOJoined(msg.sender, _id);
    }

    function donate(uint256 daoId, uint256 _donationAmount) public {
        // Transfer USDT to sub-DAO Treasury
        address _treasuryAddress = address(
            GIV3_TREASURY_FACTORY.getTreasury(daoId)
        );

        USDT.transferFrom(msg.sender, _treasuryAddress, _donationAmount);

        // Update Donated amount onto user's subDAO NFT
        GIV3_NFT_FACTORY.getCollection(daoId).addDonation(_donationAmount);
    }

    function getContract(uint256 _id) public view returns (address) {
        return daoIds[_id].contractAddress;
    }

    function getPowerLevels(uint256 _id, uint256 _tokenId)
        public
        view
        returns (uint256)
    {
        return GIV3_NFT_FACTORY.getCollection(_id).getPowerLevel(_tokenId);
    }

    function hasJoinedDAO(uint256 _id) public view returns (bool) {
        return GIV3_NFT_FACTORY.getCollection(_id).balanceOf(msg.sender) > 0;
    }
}
