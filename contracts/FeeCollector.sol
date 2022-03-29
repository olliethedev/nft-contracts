// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";

contract FeeCollector is Ownable {
    event Received(address indexed, uint);
    event CalledFallback(address indexed, uint);
    event WithdrawBalance(address indexed, uint);

    constructor() Ownable() {}

    function withdraw() public onlyOwner{
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
        emit WithdrawBalance(owner(), balance);
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