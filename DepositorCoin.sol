//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import {ERC20} from "./ERC20.sol";

contract DepositorCoin is ERC20 {
    address public owner;

    constructor() ERC20("DepositorCoin", "DPC"){
        owner = msg.sender;
    }

    function mint(address to, uint256 amount) external {
        require (msg.sender == owner,"Only Owner Alowed");
        _mint(to,amount);
    }
    
    function _burn(address from, uint256 value) external {
        require (msg.sender == owner,"Only Owner Alowed");
        burn(from, value);
    }

}