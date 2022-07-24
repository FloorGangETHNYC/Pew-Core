// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./Base64.sol";
import "./interface/IGiv3Core.sol";
import "./interface/IImageStorage.sol";

contract Giv3NFT is ERC721, ReentrancyGuard {
    using Strings for uint256;

    // Store data about the contributions made by a user holding the token
    struct Contribution {
        string ipfsHash;
        uint256 upvotes;
        uint256 downvotes;
    }

    mapping(uint256 => Contribution[]) contributions;
    mapping(uint256 => uint256) donations;
    mapping(uint256 => uint256) experience;
    mapping(uint256 => uint256) energy;
    mapping(uint256 => uint256) mintedTime;

    IGiv3Core public GIV3_CORE;
    IImageStorage public IMAGE_STORAGE;
    string public baseURI;

    // The tokenId of the next token to be minted.
    uint128 internal _currentIndex;

    // Weight Multipliers for the different types of contributions
    uint256[3] public mul = [1, 1, 1];

    uint256 public collectionIndex;

    mapping(address => uint256) public tokenMapping;

    event DonationAdded(
        address indexed user,
        uint256 indexed tokenId,
        uint256 amount
    );

    event ExperienceAdded(
        address indexed user,
        uint256 indexed tokenId,
        uint256 amount
    );

    event EnergyAdded(
        address indexed user,
        uint256 indexed tokenId,
        uint256 amount
    );

    constructor(
        string memory name_,
        string memory symbol_,
        IGiv3Core _giv3Core,
        uint256 _collectionIndex,
        IImageStorage _imageStorageAddress // ImageStorageStatic Address
    ) ERC721(name_, symbol_) {
        GIV3_CORE = _giv3Core;
        IMAGE_STORAGE = _imageStorageAddress;
        collectionIndex = _collectionIndex;
    }

    modifier onlyGiv3() {
        require(msg.sender == address(GIV3_CORE));
        _;
    }

    function mint(address _to)
        external
        onlyGiv3
        nonReentrant
        returns (uint256)
    {
        require(
            balanceOf(msg.sender) == 0,
            "Cannot mint more than one token at a time"
        );
        _safeMint(_to, _currentIndex);
        mintedTime[_currentIndex] = block.timestamp;
        tokenMapping[msg.sender] = _currentIndex;
        _currentIndex++;
        return _currentIndex - 1;
    }

    /**
     * R@notice Add Update Donation balance.
     */
    function addDonation(uint256 amount) external onlyGiv3 {
        uint256 tokenId = tokenMapping[msg.sender];

        donations[tokenId] += amount;
        emit DonationAdded(msg.sender, tokenId, amount);
    }

    /**
     * R@notice Add Update Experience balance.
     */
    function addExperience(uint256 amount, uint256 tokenId) external onlyGiv3 {
        require(
            tx.origin == ownerOf(tokenId),
            "Only the owner can add a contribution"
        );

        experience[tokenId] += amount;
        emit ExperienceAdded(msg.sender, tokenId, amount);
    }

    /**
     * R@notice Add Update Energy balance.
     */
    function addEnergy(uint256 amount, uint256 tokenId) external onlyGiv3 {
        require(
            tx.origin == ownerOf(tokenId),
            "Only the owner can add a contribution"
        );

        energy[tokenId] += amount;
        emit EnergyAdded(msg.sender, tokenId, amount);
    }

    /**
     * Get Total Supply of Tokens Minted
     * @return Current Total Supply
     */
    function totalSupply() public view returns (uint256) {
        return _currentIndex;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     * @dev gets baseURI from contract state variable
     */
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        return buildMetadata(tokenId);
    }

    /// @notice Builds the metadata required in accordance ot Opensea requirements
    /// @param _tokenId Policy ID which will also be the NFT token ID
    /// @dev Can change public to internal
    function buildMetadata(uint256 _tokenId)
        public
        view
        returns (string memory)
    {
        uint256 _powerlevel = getPowerLevel(_tokenId);
        string memory image;
        // NFTS that level up based on the governance score of the token.
        // Get Image from Image Storage Contract
        image = IMAGE_STORAGE.getImageForCollection(
            collectionIndex,
            _powerlevel
        );
        bytes memory m1 = abi.encodePacked(
            '{"name":"',
            name(),
            " Membership",
            '", "description":"',
            name(),
            " Membership",
            '", "image": "',
            image,
            // adding policyHolder
            '", "attributes": [{"trait_type":"Power Level",',
            '"value":"',
            Strings.toString(_powerlevel),
            '"}]}'
        );

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(bytes.concat(m1))
                )
            );
    }

    function getUpvotes(uint256 tokenId, uint256 index)
        public
        view
        returns (uint256)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        return contributions[tokenId][index].upvotes;
    }

    function getDownvotes(uint256 tokenId, uint256 index)
        public
        view
        returns (uint256)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        return contributions[tokenId][index].downvotes;
    }

    function getTotalUpvotes(uint256 tokenId)
        public
        view
        returns (uint256 _totalUpvotes)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        for (uint256 i = 0; i < contributions[tokenId].length; i++) {
            _totalUpvotes += contributions[tokenId][i].upvotes;
        }
        return _totalUpvotes;
    }

    function getTotalDownvotes(uint256 tokenId)
        public
        view
        returns (uint256 _totalDownvotes)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        for (uint256 i = 0; i < contributions[tokenId].length; i++) {
            _totalDownvotes += contributions[tokenId][i].downvotes;
        }
        return _totalDownvotes;
    }

    function getContribution(uint256 tokenId, uint256 index)
        public
        view
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        return
            string(
                abi.encodePacked(
                    "https://ipfs.io/ipfs/",
                    contributions[tokenId][index].ipfsHash
                )
            );
    }

    function getAllContributions(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        string memory contributionsString = "";
        for (uint256 i = 0; i < contributions[tokenId].length; i++) {
            if (i + 1 < contributions[tokenId].length) {
                string(
                    abi.encodePacked(
                        contributionsString,
                        "https://ipfs.io/ipfs/",
                        contributions[tokenId][i].ipfsHash,
                        ","
                    )
                );
            } else {
                string(
                    abi.encodePacked(
                        contributionsString,
                        "https://ipfs.io/ipfs/",
                        contributions[tokenId][i].ipfsHash
                    )
                );
            }
        }
        return contributionsString;
    }

    function getContributionCount(uint256 tokenId)
        public
        view
        returns (uint256 _contributionCount)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        return contributions[tokenId].length;
    }

    function getTimeScore(uint256 tokenId) public view returns (uint256) {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        return (block.timestamp - mintedTime[tokenId]) / 1 days;
    }

    function getDonationScore(uint256 tokenId) public view returns (uint256) {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        return donations[tokenId];
    }

    function getExperienceScore(uint256 tokenId) public view returns (uint256) {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        return experience[tokenId];
    }

    function getEnergyScore(uint256 tokenId) public view returns (uint256) {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        return energy[tokenId];
    }

    function getPowerLevel(uint256 tokenId)
        public
        view
        returns (uint256 _powerLevel)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        uint256 _donationScore = getDonationScore(tokenId);
        uint256 _experienceScore = getExperienceScore(tokenId);
        uint256 _energyScore = getEnergyScore(tokenId);

        _powerLevel =
            mul[0] *
            _donationScore +
            mul[1] *
            _experienceScore +
            mul[2] *
            _energyScore;

        return _powerLevel;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal pure override {
        // Prevent Future Transfer of token
        require(from == address(0), "ERC721: transfer from non-zero address");
    }
}
