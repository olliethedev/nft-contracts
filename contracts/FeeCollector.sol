// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";

contract FeeCollector is Ownable {
    event Received(address indexed, uint);
    event CalledFallback(address indexed, uint);

    constructor() Ownable() {}

    function withdraw() public onlyOwner{
        payable(owner()).transfer(address(this).balance);
    }
    
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
    fallback() external payable {
        emit CalledFallback(msg.sender, msg.value);
    }
    function getBalance() public view returns (uint256){
        return address(this).balance;
    }
}