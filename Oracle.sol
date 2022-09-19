//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
contract Oracle{
    address public owner;
    uint256 private price_in_usd;

    constructor() {
        owner = msg.sender;
    }

    function getPrice() public view returns (uint256) {
        return price_in_usd ;
    }

    function updatePrice(uint256 newPrice) external {
        require (owner == msg.sender,"Oracle: Only Owner");
        price_in_usd = newPrice;
    }
}