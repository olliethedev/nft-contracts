// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFT is ERC721 {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  constructor(string memory tokenName, string memory symbol) ERC721(tokenName, symbol) {
  }

  function mintToken(address owner)
  public
  returns (uint256)
  {
    _tokenIds.increment();

    uint256 id = _tokenIds.current();
    _safeMint(owner, id);

    return id;
  }
  function _baseURI() override internal pure returns (string memory) {
        return "http://localhost:8080";
    }
}