# ERC20 Vault Factory with On-Chain SVG NFT

A deterministic **ERC20 vault factory** that deploys token-specific vaults using **CREATE2**, allows users to deposit tokens, and mints a **fully on-chain SVG NFT receipt** representing the vault position.

The project demonstrates core DeFi architecture patterns including deterministic deployments, vault accounting, and on-chain NFT metadata generation.

---

## Overview

This protocol allows users to deposit any ERC20 token into a vault.

When the first deposit for a token occurs:

1. A **vault is deterministically deployed using CREATE2**
2. The deposit is transferred to the vault
3. An **NFT receipt is minted**
4. The NFT metadata contains **fully on-chain SVG artwork** displaying vault information

Each ERC20 token can only have **one vault**, guaranteeing deterministic vault infrastructure.

---

## Architecture

```
User
 │
 ▼
VaultFactory.deposit(token, amount)
 │
 ├── CREATE2 deploy Vault (if not exists)
 ├── Transfer ERC20 tokens → Vault
 └── Mint VaultNFT receipt
```

### Contracts

| Contract           | Description                                       |
| ------------------ | ------------------------------------------------- |
| `VaultFactory.sol` | Deploys vaults using CREATE2 and manages deposits |
| `Vault.sol`        | Stores ERC20 tokens and deposit accounting        |
| `VaultNFT.sol`     | ERC721 receipt NFT with fully on-chain SVG        |

---

## CREATE2 Deterministic Deployment

Vaults are deployed using **CREATE2**, allowing their addresses to be predicted before deployment.

```
salt = keccak256(token)

vault = address(
    new Vault{salt: salt}(token)
)
```

Address calculation follows:

```
address =
keccak256(
  0xff,
  factory,
  salt,
  keccak256(bytecode)
)[12:]
```

Benefits:

* deterministic infrastructure
* no duplicate vault deployments
* predictable vault addresses for integrations

---

## Vault System

Each vault manages a single ERC20 token.

### State

```
IERC20 public token;
uint256 public totalDeposits;
mapping(address => uint256) public deposits;
```

### Deposit Flow

```
User → Factory.deposit()
      → Vault receives tokens
      → NFT receipt minted
```

Vaults maintain per-user deposit accounting.

---

## NFT Receipt

Each deposit mints a **VaultNFT**.

The NFT metadata is generated entirely **on-chain**.

### NFT Metadata

```
{
  "name": "Vault #1",
  "description": "ERC20 Vault NFT representing a vault deployment",
  "image": "data:image/svg+xml;base64,..."
}
```

### SVG Artwork

The NFT SVG displays:

```
ERC20 Vault

Vault ID
Token Address
Vault Address
Deposit Amount
```

Example visual:

```
ERC20 Vault
Vault ID: 1
Token: 0xA0b8...
Vault: 0x1234...
Deposited: 1000
```

---

## Testing

The project uses **Foundry** for testing and **mainnet forking**.

Mainnet fork testing allows interaction with **real tokens**.

### Example Token Used

USDC:

```
0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
```

Whale account used for testing:

```
0x55FE002aefF02F77364de339a1292923A15844B8
```

---

### Test Coverage

The test suite validates:

| Test                | Description                                      |
| ------------------- | ------------------------------------------------ |
| Vault creation      | Vault deployed on first deposit                  |
| Token transfer      | ERC20 tokens move to vault                       |
| NFT mint            | Receipt NFT minted after deposit                 |
| Vault reuse         | Existing vault reused for same token             |
| Zero deposit        | Transaction reverts                              |
| CREATE2 determinism | Predicted vault address matches deployed address |
| Integration         | Mainnet fork deposit flow works                  |

---

## Running Tests

Install dependencies:

```
forge install
```

Add a mainnet RPC endpoint to `foundry.toml`:

```
[rpc_endpoints]
mainnet = "https://eth-mainnet.g.alchemy.com/v2/YOUR_KEY"
```

Run tests:

```
forge test -vv
```

---

## Checking the NFT SVG

To inspect the generated NFT artwork:

1. Call `tokenURI()` in a test
2. Decode the returned Base64 metadata
3. Extract the `image` field
4. Decode again to view the SVG

Example:

```
data:image/svg+xml;base64,...
```

Opening this in a browser renders the NFT image.

---

## Key Concepts Demonstrated

This project demonstrates several important blockchain engineering concepts:

* CREATE2 deterministic contract deployment
* ERC20 token integration
* Vault architecture
* On-chain NFT metadata
* Base64 encoded SVG artwork
* Mainnet fork testing
* Receipt NFTs for protocol positions

---

## Project Structure

```
src/
 ├── Vault.sol
 ├── VaultFactory.sol
 └── VaultNFT.sol

test/
 └── VaultTest.t.sol
```

---

## Potential Extensions

Future improvements could include:

* ERC4626 vault standard
* Withdraw functionality
* Dynamic NFT metadata updates
* Token symbol display in SVG
* Multi-token vault analytics

---

## License

MIT
