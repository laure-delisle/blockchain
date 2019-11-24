pragma solidity ^0.5.0;

import "@openzeppelin/contracts/token/ERC721/ERC721Full.sol";
import "@openzeppelin/contracts/drafts/Counters.sol";

contract AnimalToken is ERC721Full {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721Full("AnimalToken", "AMT") public {
    }

    function createToken(string memory tokenURI) public returns (uint256) {
        _tokenIds.increment();

        uint256 animalId = _tokenIds.current();
        _mint(msg.sender, animalId);
        _setTokenURI(animalId, tokenURI);

        return animalId;
    }
}