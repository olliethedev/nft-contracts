// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "./ERC721A.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NFT is ERC721A, Ownable, ReentrancyGuard {
  using Counters for Counters.Counter;
  using SafeMath for uint256;
  uint256 private _mintCost;
  uint256 private _maxSupply;
  bool private _isPublicMintEnabled;
  uint256 private _freeSupply;
  uint256 private _freeMintLimit;
  
  /**
  * @dev Initializes the contract setting the `tokenName` and `symbol` of the nft, `cost` of each mint call, and maximum `supply` of the nft.
  * Note: `cost` is in wei. 
  */
  constructor(string memory tokenName, string memory symbol, uint256 cost, uint256 supply) ERC721A(tokenName, symbol) Ownable() {
    _mintCost = cost;
    _maxSupply = supply;
    _isPublicMintEnabled = false;
    _freeSupply = 0;
    _freeMintLimit = 1;
  }

  /**
  * @dev Changes contract state to enable public access to `mintTokens` function
  * Can only be called by the current owner.
  */
  function allowPublicMint()
  public
  onlyOwner{
    _isPublicMintEnabled = true;
  }

  /**
  * @dev Changes contract state to disable public access to `mintTokens` function
  * Can only be called by the current owner.
  */
  function denyPublicMint()
  public
  onlyOwner{
    _isPublicMintEnabled = false;
  }

  /**
  * @dev Mint `count` tokens if requirements are satisfied.
  * 
  */
  function mintTokens(uint256 count)
  public
  payable
  nonReentrant{
    require(_isPublicMintEnabled, "Mint disabled");
    require(count > 0 && count <= 100, "You can drop minimum 1, maximum 100 NFTs");
    require(count.add(totalSupply()) <= _maxSupply, "Exceeds max supply");
    require(owner() == msg.sender || msg.value >= _mintCost.mul(count),
           "Ether value sent is below the price");
    
    _mint(msg.sender, count);
  }

  /**
  * @dev Mint a token to each Address of `recipients`.
  * Can only be called if requirements are satisfied.
  */
  function mintTokens(address[] calldata recipients)
  public
  payable
  nonReentrant{
    require(recipients.length>0,"Missing recipient addresses");
    require(owner() == msg.sender || _isPublicMintEnabled, "Mint disabled");
    require(recipients.length > 0 && recipients.length <= 100, "You can drop minimum 1, maximum 100 NFTs");
    require(recipients.length.add(totalSupply()) <= _maxSupply, "Exceeds max supply");
    require(owner() == msg.sender || msg.value >= _mintCost.mul(recipients.length),
           "Ether value sent is below the price");
    for(uint i=0; i<recipients.length; i++){
        _mint(recipients[i], 1);
     }
  }

  /**
  * @dev Mint `count` tokens if requirements are satisfied.
  */
  function freeMint(uint256 count) 
  public 
  payable 
  nonReentrant{
    require(owner() == msg.sender || _isPublicMintEnabled, "Mint disabled");
    require(totalSupply() + count <= _freeSupply, "Exceed max free supply");
    require(count <= _freeMintLimit, "Cant mint more than mint limit");
    require(count > 0, "Must mint at least 1 token");

    _safeMint(msg.sender, count);
  }

  /**
  * @dev Update the cost to mint a token.
  * Can only be called by the current owner.
  */
  function setCost(uint256 cost) public onlyOwner{
    _mintCost = cost;
  }

  /**
  * @dev Update the max supply.
  * Can only be called by the current owner.
  */
  function setMaxSupply(uint256 max) public onlyOwner{
    _maxSupply = max;
  }

  /**
  * @dev Update the max free supply.
  * Can only be called by the current owner.
  */
  function setFreeSupply(uint256 max) public onlyOwner{
    _freeSupply = max;
  }
  /**
  * @dev Update the free mint transaction limit.
  * Can only be called by the current owner.
  */
  function setFreeMintLimit(uint256 max) public onlyOwner{
    _freeMintLimit = max;
  }

  /**
  * @dev Transfers contract balance to contract owner.
  * Can only be called by the current owner.
  */
  function withdraw() public onlyOwner{
    payable(owner()).transfer(address(this).balance);
  }

  /**
  * @dev Used by public mint functions and by owner functions.
  * Can only be called internally by other functions.
  */
  function _mint(address to, uint256 count) internal virtual returns (uint256){
    _safeMint(to, count);

    return count;
  }

  function getState() public view returns (bool, uint256, uint256, uint256, uint256, uint256){
    return (_isPublicMintEnabled, _mintCost, _maxSupply, totalSupply(), _freeSupply, _freeMintLimit);
  }
  function getCost() public view returns (uint256){
    return _mintCost;
  }
  function getMaxSupply() public view returns (uint256){
    return _maxSupply;
  }
  function getCurrentSupply() public view returns (uint256){
    return totalSupply();
  }
  function getMintStatus() public view returns (bool) {
    return _isPublicMintEnabled;
  }
  function getFreeSupply() public view returns (uint256) {
    return _freeSupply;
  }
  function getFreeMintLimit() public view returns (uint256) {
    return _freeMintLimit;
  }
  function _baseURI() override internal pure returns (string memory) {
    return "https://mw9spidhbc.execute-api.us-east-1.amazonaws.com/dev/token/new-smol-kongz/";
  }
  function contractURI() public pure returns (string memory) {
    return "https://mw9spidhbc.execute-api.us-east-1.amazonaws.com/dev/contract/new-smol-kongz";
  }
}