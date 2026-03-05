// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";

import "../src/VaultFactory.sol";
import "../src/VaultNFT.sol";
import "../src/Vault.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract VaultTest is Test {
    VaultFactory factory;
    VaultNFT nft;

    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    address constant USDC_WHALE = 0x55FE002aefF02F77364de339a1292923A15844B8;

    uint256 constant DEPOSIT_AMOUNT = 1000e6;

    function setUp() public {
        // vm.createSelectFork(vm.rpcUrl("MAINNET_RPC_URL"));

        vm.createSelectFork(vm.envString("MAINNET_RPC_URL"));

        // deploy NFT
        nft = new VaultNFT();

        // deploy factory
        factory = new VaultFactory(address(nft));

        // give factory permission to mint NFTs
        nft.transferOwnership(address(factory));
    }

    // MAIN FUNCTIONAL TEST

    function testTokenURI() public {
        vm.startPrank(USDC_WHALE);

        IERC20(USDC).approve(address(factory), DEPOSIT_AMOUNT);

        factory.deposit(USDC, DEPOSIT_AMOUNT);

        vm.stopPrank();

        string memory uri = nft.tokenURI(1);

        console.log(uri);
    }

    function testDepositCreatesVaultAndMintsNFT() public {
        vm.startPrank(USDC_WHALE);

        IERC20(USDC).approve(address(factory), DEPOSIT_AMOUNT);

        factory.deposit(USDC, DEPOSIT_AMOUNT);

        vm.stopPrank();

        address vault = factory.vaultForToken(USDC);

        assertTrue(vault != address(0));

        uint256 balance = IERC20(USDC).balanceOf(vault);

        assertEq(balance, DEPOSIT_AMOUNT);

        assertEq(nft.balanceOf(USDC_WHALE), 1);
    }

    // VAULT NOT REDEPLOYED

    function testVaultNotRedeployed() public {
        vm.startPrank(USDC_WHALE);

        IERC20(USDC).approve(address(factory), DEPOSIT_AMOUNT * 2);

        factory.deposit(USDC, DEPOSIT_AMOUNT);

        address vault1 = factory.vaultForToken(USDC);

        factory.deposit(USDC, DEPOSIT_AMOUNT);

        address vault2 = factory.vaultForToken(USDC);

        vm.stopPrank();

        assertEq(vault1, vault2);
    }

    // ZERO DEPOSIT REVERT

    function testDepositRevertsIfZero() public {
        vm.expectRevert("amount zero");

        factory.deposit(USDC, 0);
    }

    // CREATE2 ADDRESS TEST

    function testCreate2DeterministicAddress() public {
        bytes32 salt = keccak256(abi.encode(USDC));

        address predicted = vm.computeCreate2Address(
            salt,
            keccak256(
                abi.encodePacked(type(Vault).creationCode, abi.encode(USDC))
            ),
            address(factory)
        );

        factory.createVault(USDC);

        address deployed = factory.vaultForToken(USDC);

        assertEq(predicted, deployed);
    }
}
