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

    address public storageContract;
    IGiv3Core public GIV3_CORE;
    string[] private z = [
        '<svg width="100%" height="100%" version="1.1" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">',
        '"<image width="32" height="32" image-rendering="pixelated" preserveAspectRatio="xMidYMid" xlink:href="',
        '"/> <image width="32" height="32" image-rendering="pixelated" preserveAspectRatio="xMidYMid" xlink:href="',
        '"/> <image width="32" height="32" image-rendering="pixelated" preserveAspectRatio="xMidYMid" xlink:href="',
        '"/> <image width="32" height="32" image-rendering="pixelated" preserveAspectRatio="xMidYMid" xlink:href="',
        '"/> <image width="32" height="32" image-rendering="pixelated" preserveAspectRatio="xMidYMid" xlink:href="',
        '"/> </svg>'
    ];

    // The tokenId of the next token to be minted.
    uint128 internal _currentIndex;

    constructor(
        string memory name_,
        string memory symbol_,
        IGiv3Core _giv3Core
    ) ERC721(name_, symbol_) {
        GIV3_CORE = _giv3Core;
    }

    modifier onlyGiv3() {
        require(msg.sender == address(GIV3_CORE));
        _;
    }

    function mint(address _to) external onlyGiv3 {
        _safeMint(_to, _currentIndex);
        _currentIndex++;
    }

    /**
     * Get Total Supply of Tokens Minted
     * @return Current Total Supply
     */
    function totalSupply() public view returns (uint256) {
        return _currentIndex;
    }

    function genPNG(CompoundImageData memory data)
        internal
        view
        returns (string memory)
    {
        // Get Token Power levels
        uint256 power_1 = data.layer_1_index;
        uint256 power_2 = data.layer_2_index;
        uint256 power_3 = data.layer_3_index;
        uint256 power_4 = data.layer_4_index;
        uint256 power_5 = data.layer_5_index;

        // Get Image Levels
        string memory layer_1 = IImageStorage(storageContract).getLayer1(
            power_1
        );
        string memory layer_2 = IImageStorage(storageContract).getLayer2(
            power_2
        );
        string memory layer_3 = IImageStorage(storageContract).getLayer3(
            power_3
        );
        string memory layer_4 = IImageStorage(storageContract).getLayer4(
            power_4
        );
        string memory layer_5 = IImageStorage(storageContract).getLayer5(
            power_5
        );

        // Get Image Data
        string memory output = string(
            abi.encodePacked(z[0], z[1], layer_1, z[2])
        );
        output = string(abi.encodePacked(output, layer_2, z[3], layer_3, z[4]));
        output = string(abi.encodePacked(output, layer_4, z[5], layer_5, z[6]));

        return output;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(_exists(tokenId), "TokenID does not exist");

        CompoundImageData memory data = CompoundImageData(
            GIV3_CORE.getPowerLevels(1, tokenId), // Shoes
            GIV3_CORE.getPowerLevels(2, tokenId), // Clothes
            GIV3_CORE.getPowerLevels(3, tokenId), // Necklace
            GIV3_CORE.getPowerLevels(4, tokenId), // Specs
            GIV3_CORE.getPowerLevels(5, tokenId) // Hat
        );

        string memory json = string(
            abi.encodePacked(
                '{"name": "',
                name(),
                "# ",
                tokenId.toString(),
                '",'
            )
        );

        json = string(
            abi.encodePacked(
                json,
                '"description": "This is a NFT of the first initial of my name!",'
            )
        );
        // hat, specs , necklace, clothes, shoes
        json = string(
            abi.encodePacked(
                json,
                '"attributes": [{"trait_type": "Hat", "value": "',
                data.layer_5_index.toString(),
                '"},',
                '{"trait_type": "Specs", "value": "',
                data.layer_4_index.toString(),
                '"},',
                '{"trait_type": "Necklace", "value": "',
                data.layer_3_index.toString(),
                '"},',
                '{"trait_type": "Clothes", "value": "',
                data.layer_2_index.toString(),
                '"}',
                '{"trait_type": "Shoes", "value": "',
                data.layer_1_index.toString(),
                '"}],'
            )
        );

        json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        json,
                        '"image_data": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(genPNG(data))),
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
