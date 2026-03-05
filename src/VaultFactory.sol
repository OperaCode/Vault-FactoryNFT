// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Vault.sol";

contract VaultFactory {

    mapping(address => address) public vaultForToken;

    event VaultCreated(address token, address vault);

    function createVault(address token) external returns (address vault) {

        require(vaultForToken[token] == address(0), "exists");

        bytes32 salt = keccak256(abi.encode(token));

        vault = address(
            new Vault{salt: salt}(token)
        );

        vaultForToken[token] = vault;

        emit VaultCreated(token, vault);
    }

}