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
  using Strings for uint256;
  Counters.Counter private _tokenIds;
  uint256 private _mintCost;
  uint256 private _maxSupply;
  string private _baseURL;
  uint256 private FEE_DENOMINATOR = 1000;
  uint256 private FEE_PLATFORM_NUMERATOR = 50;
  uint256 private FEE_OWNER_NUMERATOR = 950;
  address private PLATFORM_FEE_ADDRESS = 0x0000000000000000000000000000000000000000;
  
  /**
  * @dev Initializes the contract setting the `tokenName` and `symbol` of the nft, `cost` of each mint call, and maximum `supply` of the nft.
  * Note: `cost` is in wei. 
  */
  constructor(string memory tokenName, string memory symbol, uint256 cost, uint256 supply, string memory baseURL) ERC721(tokenName, symbol) Ownable() {
    _mintCost = cost;
    _maxSupply = supply;
    _baseURL = baseURL;
  }

  /**
  * @dev Mint `count` tokens if requirements are satisfied.
  * 
  */
  function mintTokens(uint256 count)
  public
  payable
  nonReentrant{
    require(count > 0 && count <= 100, "You can drop minimum 1, maximum 100 NFTs");
    require(count.add(_tokenIds.current()) < (_maxSupply+1), "Exceeds max supply");
    require(owner() == msg.sender || msg.value >= _mintCost.mul(count),
           "Ether value sent is below the price");
    
    for(uint i=0; i<count; i++){
        _mint(msg.sender);
    }
    payable(owner()).transfer(msg.value.mul(FEE_OWNER_NUMERATOR).div(FEE_DENOMINATOR));
    payable(PLATFORM_FEE_ADDRESS).transfer(msg.value.mul(FEE_PLATFORM_NUMERATOR).div(FEE_DENOMINATOR));
  }

   /**
  * @dev Mint a token to each Address of `recipients`.
  * Can only be called if requirements are satisfied.
  */
  function adminMintTokens(address[] calldata recipients)
  public
  payable
  onlyOwner
  nonReentrant{
    require(recipients.length>0,"Missing recipient addresses");
    require(recipients.length > 0 && recipients.length <= 100, "You can drop minimum 1, maximum 100 NFTs");
    require(recipients.length.add(_tokenIds.current()) < (_maxSupply+1), "Exceeds max supply");
    
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

  function _baseURI() override internal view returns (string memory) {
    return _baseURL;
  }

  function tokenURI(uint256 tokenId) public view override returns (string memory) {
    require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

    string memory baseURI = _baseURI();
    return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString(), "/metadata.json")) : "";
  }

  function contractURI() public view returns (string memory) {
    string memory baseURI = _baseURI();
    return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, "metadata.json")) : "";
  }
}