pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
    uint256 public constant tokensPerEth = 100;
    event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
    event SellTokens(
        address buyer,
        uint256 amountOfETH,
        uint256 amountOfTokens
    );
    YourToken public yourToken;

    constructor(address tokenAddress) {
        yourToken = YourToken(tokenAddress);
    }

    function buyTokens() public payable {
        uint256 tokens = msg.value * tokensPerEth;
        yourToken.transfer(msg.sender, tokens);
        emit BuyTokens(msg.sender, msg.value, tokens);
    }

    function withdraw() public payable onlyOwner {
        (bool sent, bytes memory data) = owner().call{
            value: address(this).balance
        }("");
        require(sent, "Failed to send Ether");
    }

    function sellTokens(uint256 tokenAmount) public payable {
        require(
            yourToken.transferFrom(msg.sender, address(this), tokenAmount),
            "Sell failed"
        );

        uint256 eth = tokenAmount / tokensPerEth;
        (bool sent, bytes memory data) = msg.sender.call{value: eth}("");
        require(sent, "Failed to send Ether");
        emit SellTokens(msg.sender, eth, tokenAmount);
    }
}
