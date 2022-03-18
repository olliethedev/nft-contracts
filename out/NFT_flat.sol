// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "./ERC721A.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol"; 

contract NFT is ERC721A, Ownable, ReentrancyGuard {
  using Counters for Counters.Counter;
  using SafeMath for uint256;
  uint256 private _mintCost;
  uint256 private _maxSupply;
  bool private _isPublicMintEnabled;
  uint256 private _freeSupply;
  uint256 private _freeMintLimit;
  string private _baseURL;
  uint256 private FEE_DENOMINATOR = 1000;
  uint256 private FEE_PLATFORM_NUMERATOR = 50;
  uint256 private FEE_OWNER_NUMERATOR = 950;
  address private PLATFORM_FEE_ADDRESS = 0x0000000000000000000000000000000000000000;

  event MintCostUpdated(uint256 _value);
  event MaxSupplyUpdated(uint256 _value);
  event PublicMintStatusChanged(bool _value);
  event FreeSupplyUpdated(uint256 _value);
  event FreeMintLimitUpdated(uint256 _value);
  event BaseUrlUpdated(string _value);
  event PlatformFeeAddressUpdated(address indexed _address);
  
  /**
  * @dev Initializes the contract setting the `tokenName` and `symbol` of the nft, `cost` of each mint call, and maximum `supply` of the nft.
  * Note: `cost` is in wei. 
  */
  constructor(string memory tokenName, string memory symbol, uint256 cost, uint256 supply, string memory baseURL, bool enablePublicMinting) ERC721A(tokenName, symbol) Ownable() {
    _mintCost = cost;
    _maxSupply = supply;
    _isPublicMintEnabled = enablePublicMinting;
    _freeSupply = 0;
    _freeMintLimit = 1;
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
    require(count > 0 && count <= 100, "You can mint minimum 1, maximum 100 NFTs");
    require(count.add(totalSupply()) <= _maxSupply, "Exceeds max supply");
    require(owner() == msg.sender || msg.value >= _mintCost.mul(count),
           "Ether value sent is below the price");
    
    if(msg.value > 0){
      payable(owner()).transfer(msg.value.mul(FEE_OWNER_NUMERATOR).div(FEE_DENOMINATOR));
      payable(owner()).transfer(msg.value.mul(FEE_PLATFORM_NUMERATOR).div(FEE_DENOMINATOR));
    }

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
    require(recipients.length > 0 && recipients.length <= 100, "You can mint minimum 1, maximum 100 NFTs");
    require(recipients.length.add(totalSupply()) <= _maxSupply, "Exceeds max supply");
    require(owner() == msg.sender || msg.value >= _mintCost.mul(recipients.length),
           "Ether value sent is below the price");
    
    if(msg.value > 0){
      payable(owner()).transfer(msg.value.mul(FEE_OWNER_NUMERATOR).div(FEE_DENOMINATOR));
      payable(owner()).transfer(msg.value.mul(FEE_PLATFORM_NUMERATOR).div(FEE_DENOMINATOR));
    }
    
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
    require(totalSupply() + count <= _freeSupply, "Exceeded max free supply");
    require(count <= _freeMintLimit, "Cant mint more than mint limit");
    require(count > 0, "Must mint at least 1 token");

    _safeMint(msg.sender, count);
  }

  /**
  * @dev Changes contract state to enable public access to `mintTokens` function
  * Can only be called by the current owner.
  */
  function enablePublicMint()
  public
  onlyOwner{
    _isPublicMintEnabled = true;
    emit PublicMintStatusChanged(true);
  }

  /**
  * @dev Changes contract state to disable public access to `mintTokens` function
  * Can only be called by the current owner.
  */
  function disablePublicMint()
  public
  onlyOwner{
    _isPublicMintEnabled = false;
    emit PublicMintStatusChanged(false);
  }

  /**
  * @dev Update the cost to mint a token.
  * Can only be called by the current owner.
  */
  function setCost(uint256 cost) public onlyOwner{
    _mintCost = cost;
    emit MintCostUpdated(cost);
  }

  /**
  * @dev Update the max supply.
  * Can only be called by the current owner.
  */
  function setMaxSupply(uint256 max) public onlyOwner{
    _maxSupply = max;
    emit MaxSupplyUpdated(max);
  }

  /**
  * @dev Update the max free supply.
  * Can only be called by the current owner.
  */
  function setFreeSupply(uint256 max) public onlyOwner{
    _freeSupply = max;
    emit FreeSupplyUpdated(max);
  }
  /**
  * @dev Update the free mint transaction limit.
  * Can only be called by the current owner.
  */
  function setFreeMintLimit(uint256 max) public onlyOwner{
    _freeMintLimit = max;
    emit FreeMintLimitUpdated(max);
  }
  /**
  * @dev Update base base uri 
  */
  function updateBaseUrl(string memory newBaseUrl) public{
    require(PLATFORM_FEE_ADDRESS == msg.sender);
    _baseURL = newBaseUrl;
    emit BaseUrlUpdated(newBaseUrl);
  }
  /**
  * @dev Update fee address
  */
  function updatePlatformFeeAddress(address newAddress) public{
    require(PLATFORM_FEE_ADDRESS == msg.sender);
    PLATFORM_FEE_ADDRESS = newAddress;
    emit PlatformFeeAddressUpdated(newAddress);
  }
  /**
  * @dev Used by public mint functions and by owner functions.
  * Can only be called internally by other functions.
  */
  function _mint(address to, uint256 count) internal virtual returns (uint256){
    _safeMint(to, count);

    return count;
  }

  function canFreeMint(uint256 count) public view returns (bool){
    return (_isPublicMintEnabled && totalSupply() + count <= _freeSupply && count <= _freeMintLimit && count > 0);
  }
  function getState() public view returns (bool, uint256, uint256, uint256, uint256, uint256, address){
    return (_isPublicMintEnabled, _mintCost, _maxSupply, totalSupply(), _freeSupply, _freeMintLimit, owner());
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
  function _baseURI() override internal view returns (string memory) {
    return _baseURL;
  }
  function tokenURI(uint256 tokenId) public view override returns (string memory) {
    require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

    string memory baseURI = _baseURI();
    return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, Strings.toString(tokenId), "/metadata.json")) : "";
  }
  function contractURI() public view returns (string memory) {
    string memory baseURI = _baseURI();
    return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, "metadata.json")) : "";
  }
}