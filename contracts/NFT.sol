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
  
  /**
  * @dev Initializes the contract setting the `tokenName` and `symbol` of the nft, `cost` of each mint call, and maximum `supply` of the nft.
  * Note: `cost` is in wei. 
  */
  constructor(string memory tokenName, string memory symbol, uint256 cost, uint256 supply) ERC721(tokenName, symbol) Ownable() {
    _mintCost = cost;
    _maxSupply = supply;
  }

  /**
  * @dev Mints a new nft if requirements are satisfied.
  */
  function mintToken()
  public
  payable
  returns (uint256)
  {
    require(_tokenIds.current() < _maxSupply, "Maximum supply reached");
    require(msg.value == _mintCost, "Caller provided invalid payment amount");
    _tokenIds.increment();

    uint256 id = _tokenIds.current();
    _safeMint(msg.sender, id);

    return id;
  }
  /**
  * @dev Transfers contract balance to contract owner.
  * Can only be called by the current owner.
  */
  function withdraw() public onlyOwner{
    payable(owner()).transfer(address(this).balance);
  }

  function getCost() public view returns (uint256){
    return _mintCost;
  }
  function totalSupply() public view returns (uint256){
    return _maxSupply;
  }
  function getCurrentSupply() public view returns (uint256){
    return _tokenIds.current();
  }
  function _baseURI() override internal pure returns (string memory) {
        return "https://4a53x0u6k3.execute-api.us-east-1.amazonaws.com/dev/token/";
  }
  function contractURI() public pure returns (string memory) {
        return "https://4a53x0u6k3.execute-api.us-east-1.amazonaws.com/dev/contract";
  }
}