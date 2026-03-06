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

    constructor() ERC721("Vault NFT", "VAULT") Ownable(msg.sender) {}

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

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
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

        return
            string(abi.encodePacked("data:application/json;base64,", metadata));
    }

    function _generateSVG(
        uint256 tokenId,
        address vault,
        address token,
        uint256 deposited
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "<svg xmlns='http://www.w3.org/2000/svg' width='500' height='500'>",
                    // background
                    "<rect width='100%' height='100%' fill='#0f172a'/>",
                    // receipt container
                    "<rect x='40' y='40' width='420' height='420' rx='12' fill='#111827' stroke='#334155' stroke-width='2'/>",
                    // title
                    "<text x='250' y='90' fill='white' font-size='26' text-anchor='middle' font-family='monospace'>",
                    "VAULT RECEIPT",
                    "</text>",
                    // divider
                    "<line x1='80' y1='110' x2='420' y2='110' stroke='#475569' stroke-width='1'/>",
                    // Vault ID label
                    "<text x='250' y='150' fill='#94a3b8' font-size='14' text-anchor='middle' font-family='monospace'>",
                    "Vault #",
                    "</text>",
                    // Vault ID value
                    "<text x='250' y='175' fill='white' font-size='12' text-anchor='middle' font-family='monospace'>",
                    tokenId.toString(),
                    "</text>",
                    // Token label
                    "<text x='250' y='220' fill='#94a3b8' font-size='14' text-anchor='middle' font-family='monospace'>",
                    "Token",
                    "</text>",
                    // Token value
                    "<text x='250' y='245' fill='white' font-size='12' text-anchor='middle' font-family='monospace'>",
                    Strings.toHexString(uint160(token), 20),
                    "</text>",
                    // Vault label
                    "<text x='250' y='290' fill='#94a3b8' font-size='14' text-anchor='middle' font-family='monospace'>",
                    "Vault Contract",
                    "</text>",
                    // Vault value
                    "<text x='250' y='315' fill='white' font-size='12' text-anchor='middle' font-family='monospace'>",
                    Strings.toHexString(uint160(vault), 20),
                    "</text>",
                    // Deposited label
                    "<text x='250' y='360' fill='#94a3b8' font-size='14' text-anchor='middle' font-family='monospace'>",
                    "Deposit Amount",
                    "</text>",
                    // Deposit value
                    "<text x='250' y='385' fill='white' font-size='12' text-anchor='middle' font-family='monospace'>",
                    deposited.toString(),
                    "</text>",
                    // footer divider
                    "<line x1='80' y1='405' x2='420' y2='405' stroke='#475569' stroke-width='1'/>",
                    // footer
                    "<text x='250' y='435' fill='#64748b' font-size='12' text-anchor='middle' font-family='monospace'>",
                    "ERC20 VAULT FACTORY",
                    "</text>",
                    "</svg>"
                )
            );
    }
}
