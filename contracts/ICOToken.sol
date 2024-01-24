// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.13;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract MyICO is ERC20, Ownable {
    using SafeMath for uint256;

    address public owner;
    uint256 public startTime;
    uint256 public constant SALE_DURATION = 1 days;
    uint256 public constant TOKEN_RATE = 100; // 1 ETH = 100 Tokens
    uint256 public constant MAX_TOKENS_FOR_SALE = 1000000 * 10**decimals(); // Maximum tokens available for sale

    event TokensPurchased(address indexed buyer, uint256 amount, uint256 tokens);

    constructor(string memory name, string memory symbol) ERC20("Abisma", "ABM") {
        owner = msg.sender;
        startTime = block.timestamp;
    }

    modifier saleOpen() {
        require(block.timestamp >= startTime && block.timestamp <= startTime.add(SALE_DURATION), "Sale is not open");
        _;
    }

    modifier saleEnded() {
        require(block.timestamp > startTime.add(SALE_DURATION), "Sale is still open");
        _;
    }

    function ownerMint(uint256 amount) external onlyOwner {
        require(totalSupply().add(amount) <= MAX_TOKENS_FOR_SALE, "Exceeds maximum tokens for sale");
        _mint(owner, amount);
    }

    function buyTokens() external payable saleOpen {
        uint256 ethAmount = msg.value;
        uint256 tokenAmount = ethAmount.mul(TOKEN_RATE);

        require(totalSupply().add(tokenAmount) <= MAX_TOKENS_FOR_SALE, "Exceeds maximum tokens for sale");

        _mint(msg.sender, tokenAmount);
        emit TokensPurchased(msg.sender, ethAmount, tokenAmount);
    }

    function withdraw() external onlyOwner saleEnded {
        payable(owner).transfer(address(this).balance);
    }
}
