// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NFT is ERC721, Ownable, ReentrancyGuard {
  using Counters for Counters.Counter;
  using SafeMath for uint256;
  Counters.Counter private _tokenIds;
  uint256 private _mintCost;
  uint256 private _maxSupply;
  bool private _isPublicMintEnabled;
  
  /**
  * @dev Initializes the contract setting the `tokenName` and `symbol` of the nft, `cost` of each mint call, and maximum `supply` of the nft.
  * Note: `cost` is in wei. 
  */
  constructor(string memory tokenName, string memory symbol, uint256 cost, uint256 supply) ERC721(tokenName, symbol) Ownable() {
    _mintCost = cost;
    _maxSupply = supply;
    _isPublicMintEnabled = false;
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
    require(count.add(_tokenIds.current()) < _maxSupply, "Exceeds max supply");
    require(owner() == msg.sender || msg.value >= _mintCost.mul(count),
           "Ether value sent is below the price");
    for(uint i=0; i<count; i++){
        _mint(msg.sender);
     }
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
    require(recipients.length.add(_tokenIds.current()) < _maxSupply, "Exceeds max supply");
    require(owner() == msg.sender || msg.value >= _mintCost.mul(recipients.length),
           "Ether value sent is below the price");
    for(uint i=0; i<recipients.length; i++){
        _mint(recipients[i]);
     }
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
  function _mint(address to) internal virtual returns (uint256){
    _tokenIds.increment();
    uint256 id = _tokenIds.current();
    _safeMint(to, id);

    return id;
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
  function getMintStatus() public view returns (bool) {
    return _isPublicMintEnabled;
  }
  function _baseURI() override internal pure returns (string memory) {
    return "https://mw9spidhbc.execute-api.us-east-1.amazonaws.com/dev/token/trick-or-nft/";
  }
  function contractURI() public pure returns (string memory) {
    return "https://mw9spidhbc.execute-api.us-east-1.amazonaws.com/dev/contract/trick-or-nft";
  }
}