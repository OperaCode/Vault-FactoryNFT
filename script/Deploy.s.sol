// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";

import "../src/VaultNFT.sol";
import "../src/VaultFactory.sol";

contract Deploy is Script {

    function run() external {

        vm.startBroadcast();

        VaultNFT nft = new VaultNFT();

        VaultFactory factory = new VaultFactory(address(nft));

        nft.transferOwnership(address(factory));

        vm.stopBroadcast();
    }
}