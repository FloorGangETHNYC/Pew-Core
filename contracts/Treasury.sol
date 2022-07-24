// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

// import erc20
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Treasury {
    uint256 public ethBalance;
    address public GIV3_CORE;
    mapping(address => uint256) public tokenBalances;

    event ETHDeposited(uint256 amount);
    event ETHWithdrawn(uint256 amount, address to);
    event TokenDeposited(IERC20 tokenAddress, uint256 amount);
    event TokenWithdrawn(IERC20 tokenAddress, uint256 amount, address to);

    modifier onlyGiv3() {
        require(msg.sender == address(GIV3_CORE));
        _;
    }

    constructor(address _giv3Core) {
        GIV3_CORE = address(_giv3Core);
    }

    function depositETH() public payable onlyGiv3 {
        ethBalance += msg.value;
        uint256 amount = msg.value;
        emit ETHDeposited(amount);
    }

    function withdrawETH(address to, uint256 amount) public payable onlyGiv3 {
        require(amount <= ethBalance, "Not enough ETH");
        ethBalance -= amount;
        to.call{value: amount}("");
        emit ETHWithdrawn(amount, to);
    }

    function depositToken(IERC20 tokenAddress, uint256 amount) public onlyGiv3 {
        require(amount > 0, "Amount must be greater than 0");
        tokenAddress.transfer(msg.sender, amount);
        emit TokenDeposited(tokenAddress, amount);
    }

    function withdrawToken(
        IERC20 tokenAddress,
        uint256 amount,
        address to
    ) public onlyGiv3 {
        require(amount > 0, "Amount must be greater than 0");
        require(
            tokenAddress.balanceOf(msg.sender) >= amount,
            "Not enough tokens"
        );
        tokenAddress.transfer(to, amount);
        emit TokenWithdrawn(tokenAddress, amount, to);
    }
}
