// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockUSDT is ERC20 {
    event Minted(address to, uint256 amount);

    /**
     * @dev Mint initial supply
     * @param initialSupply Initial supply of tokens
     */
    constructor(uint256 initialSupply) ERC20("USDT", "USDT") {
        _mint(msg.sender, initialSupply);
    }

    /**
     * @notice  Burn `amount` tokens and decreasing the total supply.
     * @param amount Amount of tokens to burn
     */
    function burn(uint256 amount) external returns (bool) {
        _burn(_msgSender(), amount);
        return true;
    }
}
