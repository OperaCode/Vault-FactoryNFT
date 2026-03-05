// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;



import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


contract VaultNFT is ERC721 {
    uint256 public id;

    constructor() ERC721("Vault NFT", "VAULT") {}

    function mint(address to) external returns(uint256) {

        id++;

        _safeMint(to, id);
 
        return id;
    }
}