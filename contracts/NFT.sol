// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFT is ERC721, Ownable {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;
  uint256 private _mintCost;
  uint256 private _maxSupply;
  
  constructor(string memory tokenName, string memory symbol, uint256 cost, uint256 supply) ERC721(tokenName, symbol) Ownable() {
    _mintCost = cost;
    _maxSupply = supply;
  }

  function mintToken(address owner)
  public
  payable
  returns (uint256)
  {
    require(_tokenIds.current() < _maxSupply, "Maximum supply reached");
    require(msg.value == _mintCost, "Caller provided invalid payment amount");
    _tokenIds.increment();

    uint256 id = _tokenIds.current();
    _safeMint(owner, id);

    return id;
  }
  function _baseURI() override internal pure returns (string memory) {
        return "http://localhost:8080";
  }
  function getCost() public view returns (uint256){
    return _mintCost;
  }
  function getMaxSupply() public view returns (uint256){
    return _maxSupply;
  }
  function getCurrentSupply() public view returns (uint256){
    return _tokenIds.current();
  }
  function withdraw() public onlyOwner{
    payable(owner()).transfer(address(this).balance);
  }
}