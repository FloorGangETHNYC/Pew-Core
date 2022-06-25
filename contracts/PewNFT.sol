// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

error URIQueryForNonexistentToken();

contract PewNFT is ERC721 {
    using Strings for uint256;

    // Store data about the contributions made by a user holding the token
    struct Contribution {
        string ipfsHash;
        uint256 upvotes;
        uint256 downvotes;
    }

    mapping(uint256 => Contribution[]) contributions;

    address public PEW_CORE;
    string public baseURI;

    // The tokenId of the next token to be minted.
    uint128 internal _currentIndex;

    event ContributionAdded(
        address indexed contributor,
        uint256 indexed tokenId,
        string ipfsHash
    );

    constructor(
        string memory name_,
        string memory symbol_,
        address _pewCore
    ) ERC721(name_, symbol_) {
        PEW_CORE = address(_pewCore);
    }

    modifier onlyPew() {
        require(msg.sender == address(PEW_CORE));
        _;
    }

    function mint(address _to) external onlyPew {
        _safeMint(_to, _currentIndex);
        _currentIndex++;
    }

    /**
     * R@notice Add Contribution to the token.
     */
    function addContribution(string memory ipfsHash, uint256 tokenId)
        external
        onlyPew
    {
        require(
            tx.origin == ownerOf(tokenId),
            "Only the owner can add a contribution"
        );

        Contribution memory contribution = Contribution(ipfsHash, 0, 0);
        contributions[tokenId].push(contribution);
        emit ContributionAdded(msg.sender, tokenId, ipfsHash);
    }

    /**
     * @notice Upvote a contribution.
     */
    function upvote(uint256 tokenId, uint256 contributionIndex)
        external
        onlyPew
    {
        Contribution storage contribution = contributions[tokenId][
            contributionIndex
        ];
        contribution.upvotes++;
    }

    /**
     * @notice Downvote a contribution.
     */
    function downvote(uint256 tokenId, uint256 contributionIndex)
        external
        onlyPew
    {
        Contribution storage contribution = contributions[tokenId][
            contributionIndex
        ];
        contribution.downvotes++;
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

        return
            bytes(baseURI).length != 0
                ? string(abi.encodePacked(baseURI, (tokenId).toString()))
                : "";
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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal pure override {
        // Prevent Future Transfer of token
        require(from == address(0), "ERC721: transfer from non-zero address");
    }
}
