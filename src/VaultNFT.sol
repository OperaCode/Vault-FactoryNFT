// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract VaultNFT is ERC721, Ownable {

    using Strings for uint256;

    uint256 public tokenIdCounter;

    struct VaultInfo {
        address vault;
        address token;
        uint256 deposited;
    }

    mapping(uint256 => VaultInfo) public vaultInfo;

    constructor() 
        ERC721("Vault NFT", "VAULT") 
        Ownable(msg.sender) 
    {}

    function mint(
        address to,
        address vault,
        address token,
        uint256 deposited
    ) external onlyOwner returns (uint256) {

        tokenIdCounter++;

        uint256 tokenId = tokenIdCounter;

        _safeMint(to, tokenId);

        vaultInfo[tokenId] = VaultInfo({
            vault: vault,
            token: token,
            deposited: deposited
        });

        return tokenId;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {

        require(_ownerOf(tokenId) != address(0), "Nonexistent");

        VaultInfo memory info = vaultInfo[tokenId];

        string memory svg = _generateSVG(
            tokenId,
            info.vault,
            info.token,
            info.deposited
        );

        string memory image = Base64.encode(bytes(svg));

        string memory metadata = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name":"Vault #',
                        tokenId.toString(),
                        '",',
                        '"description":"ERC20 Vault NFT representing a vault deployment",',
                        '"image":"data:image/svg+xml;base64,',
                        image,
                        '"}'
                    )
                )
            )
        );

        return string(
            abi.encodePacked("data:application/json;base64,", metadata)
        );
    }

    function _generateSVG(
        uint256 tokenId,
        address vault,
        address token,
        uint256 deposited
    ) internal pure returns (string memory) {

        return string(
            abi.encodePacked(
                "<svg xmlns='http://www.w3.org/2000/svg' width='500' height='500'>",

                "<rect width='100%' height='100%' fill='black'/>",

                "<text x='50%' y='20%' fill='white' font-size='22' text-anchor='middle'>",
                "ERC20 Factory Vault",
                "</text>",

                "<text x='50%' y='40%' fill='white' font-size='16' text-anchor='middle'>",
                "Vault ID: ",
                tokenId.toString(),
                "</text>",

                "<text x='50%' y='55%' fill='white' font-size='14' text-anchor='middle'>",
                "Token: ",
                Strings.toHexString(uint160(token), 20),
                "</text>",

                "<text x='50%' y='70%' fill='white' font-size='14' text-anchor='middle'>",
                "Vault: ",
                Strings.toHexString(uint160(vault), 20),
                "</text>",

                "<text x='50%' y='85%' fill='white' font-size='14' text-anchor='middle'>",
                "Deposited: ",
                deposited.toString(),
                "</text>",

                "</svg>"
            )
        );
    }
}