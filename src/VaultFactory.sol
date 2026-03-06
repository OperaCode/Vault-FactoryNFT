// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Vault.sol";
import "./VaultNFT.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract VaultFactory {

    mapping(address => address) public vaultForToken;

    VaultNFT public vaultNFT;

    event VaultCreated(address token, address vault);
    event Deposited(address user, address vault, uint256 amount);

    constructor(address _vaultNFT) {
        vaultNFT = VaultNFT(_vaultNFT);
    }

    function createVault(address token) public returns (address vault) {

        require(vaultForToken[token] == address(0), "Vault exists");

        bytes32 salt = keccak256(abi.encode(token));

        vault = address(new Vault{salt: salt}(token));

        vaultForToken[token] = vault;

        emit VaultCreated(token, vault);
    }

    function deposit(address token, uint256 amount) external {

    require(amount > 0, "amount zero");

    address vault = vaultForToken[token];

    if (vault == address(0)) {
        vault = createVault(token);
    }

    // transfer tokens to factory first
    IERC20(token).transferFrom(msg.sender, address(this), amount);

    // approve vault
    IERC20(token).approve(vault, amount);

    // deposit into vault
    Vault(vault).deposit(amount);

    vaultNFT.mint(
        msg.sender,
        vault,
        token,
        amount
    );

    emit Deposited(msg.sender, vault, amount);
}

}