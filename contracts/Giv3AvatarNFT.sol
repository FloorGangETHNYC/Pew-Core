// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./Base64.sol";
import "./interface/IImageStorage.sol";
import "./interface/IGiv3Core.sol";

contract Giv3AvatarNFT is ERC721 {
    using Strings for uint256;

    struct CompoundImageData {
        uint256 layer_1_index;
        uint256 layer_2_index;
        uint256 layer_3_index;
        uint256 layer_4_index;
        uint256 layer_5_index;
    }

    IImageStorage public DYNAMIC_IMAGE_STORAGE;
    IGiv3Core public GIV3_CORE;
    string[] private z = [
        '<svg width="100%" height="100%" version="1.1" viewBox="0 0 560 560" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">',
        '"<image width="560" height="560" image-rendering="pixelated" preserveAspectRatio="xMidYMid" xlink:href="', // add base
        '"/> <image width="560" height="560" image-rendering="pixelated" preserveAspectRatio="xMidYMid" xlink:href="', // add shoes
        '"/> <image width="560" height="560" image-rendering="pixelated" preserveAspectRatio="xMidYMid" xlink:href="', // add clothes
        '"/> <image width="560" height="560" image-rendering="pixelated" preserveAspectRatio="xMidYMid" xlink:href="', // add necklace
        '"/> <image width="560" height="560" image-rendering="pixelated" preserveAspectRatio="xMidYMid" xlink:href="', // add specs
        '"/> <image width="560" height="560" image-rendering="pixelated" preserveAspectRatio="xMidYMid" xlink:href="', // add hat
        '"/> </svg>'
    ];

    // The tokenId of the next token to be minted.
    uint128 internal _currentIndex;

    mapping(address => uint256) public tokenMapping;

    constructor(
        string memory name_,
        string memory symbol_,
        IGiv3Core _giv3Core,
        IImageStorage _imageStorage
    ) ERC721(name_, symbol_) {
        GIV3_CORE = _giv3Core;
        DYNAMIC_IMAGE_STORAGE = _imageStorage;
    }

    modifier onlyGiv3() {
        require(msg.sender == address(GIV3_CORE));
        _;
    }

    function mint(address _to) external onlyGiv3 {
        _safeMint(_to, _currentIndex);
        tokenMapping[tx.origin] = _currentIndex;
        _currentIndex++;
    }

    /**
     * Get Total Supply of Tokens Minted
     * @return Current Total Supply
     */
    function totalSupply() public view returns (uint256) {
        return _currentIndex;
    }

    function genPNG(
        uint256 power_1,
        uint256 power_2,
        uint256 power_3,
        uint256 power_4,
        uint256 power_5
    ) internal view returns (string memory) {
        // Get Image Levels
        string memory base = DYNAMIC_IMAGE_STORAGE.getBody();
        string memory layer_1 = DYNAMIC_IMAGE_STORAGE.getLayer1(power_1);
        string memory layer_2 = DYNAMIC_IMAGE_STORAGE.getLayer2(power_2);
        string memory layer_3 = DYNAMIC_IMAGE_STORAGE.getLayer3(power_3);
        string memory layer_4 = DYNAMIC_IMAGE_STORAGE.getLayer4(power_4);
        string memory layer_5 = DYNAMIC_IMAGE_STORAGE.getLayer5(power_5);

        // Get Image Data
        string memory output = string(abi.encodePacked(z[0], z[1], base, z[2]));
        output = string(abi.encodePacked(output, layer_1, z[3]));
        output = string(abi.encodePacked(output, layer_2, z[4], layer_3, z[5]));
        output = string(abi.encodePacked(output, layer_4, z[6], layer_5, z[7]));

        return output;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(_exists(tokenId), "TokenID does not exist");

        uint256 _power_1 = GIV3_CORE.getPowerLevels(0, tokenId);
        uint256 _power_2 = GIV3_CORE.getPowerLevels(1, tokenId);
        uint256 _power_3 = GIV3_CORE.getPowerLevels(2, tokenId);
        uint256 _power_4 = GIV3_CORE.getPowerLevels(3, tokenId);
        uint256 _power_5 = GIV3_CORE.getPowerLevels(4, tokenId);

        string memory json = string(
            abi.encodePacked(
                '{"name": "',
                name(),
                "# ",
                tokenId.toString(),
                '",'
            )
        );
        json = string(abi.encodePacked(json, '"description": "Giv3 NFT!",'));
        // hat, specs , necklace, clothes, shoes
        json = string(
            abi.encodePacked(
                json,
                '"attributes": [{"trait_type": "Hat", "value": "',
                _power_5.toString(),
                '"},',
                '{"trait_type": "Specs", "value": "',
                _power_4.toString(),
                '"},',
                '{"trait_type": "Necklace", "value": "',
                _power_3.toString(),
                '"},',
                '{"trait_type": "Clothes", "value": "',
                _power_2.toString(),
                '"},',
                '{"trait_type": "Shoes", "value": "',
                _power_1.toString(),
                '"}],'
            )
        );
        json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        json,
                        '"image_data": "data:image/svg+xml;base64,',
                        Base64.encode(
                            bytes(
                                genPNG(
                                    _power_1,
                                    _power_2,
                                    _power_3,
                                    _power_4,
                                    _power_5
                                )
                            )
                        ),
                        '"}'
                    )
                )
            )
        );
        return string(abi.encodePacked("data:application/json;base64,", json));
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
