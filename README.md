# ERC-4626 Vault Lab

A tokenized vault built on OpenZeppelin's ERC-4626 implementation. Users deposit a six-decimal mock token and receive transferable vault shares. A separate `donateYield` function adds tokens without minting shares to simulate yield and expose the share-price math.

This is a study project, not an investment strategy or an audited vault. It must not hold real funds.

## Mechanics

- `deposit` and `mint` exchange underlying assets for shares.
- `withdraw` and `redeem` burn shares for assets.
- `previewDeposit`, `previewMint`, `previewWithdraw`, and `previewRedeem` estimate exact operation costs or proceeds under the current on-chain state.
- The vault uses OpenZeppelin's virtual shares/assets and a six-decimal share offset to reduce rounding loss and first-deposit inflation risk. This is a mitigation, not a guarantee for every possible integration.
- `donateYield` transfers assets in, increasing the value of existing shares. It does **not** earn yield.

The underlying token in tests is an unrestricted mintable mock. It is never suitable as a real stablecoin.

## Run

Requirements: Git and Foundry v1.8.5.

```bash
mkdir -p lib
git clone --depth 1 --branch v5.6.1 https://github.com/OpenZeppelin/openzeppelin-contracts.git lib/openzeppelin-contracts
git clone --depth 1 --branch v1.17.0 https://github.com/foundry-rs/forge-std.git lib/forge-std
forge build
forge test -vv
```

The CI workflow runs the same commands. See [EIP-4626](https://eips.ethereum.org/EIPS/eip-4626) and the [OpenZeppelin ERC-4626 guide](https://docs.openzeppelin.com/contracts/5.x/erc4626) for the standard and inflation-attack discussion.
Use [STUDY_GUIDE.md](STUDY_GUIDE.md) to walk through the share math and make your own change before publication.

## Security and design limits

- There is no external strategy, price oracle, harvest operation, management role, fee, or guarantee of returns.
- A direct token transfer to the vault also changes share price. Integrators must use the relevant `preview*` method immediately before an operation and consider transaction ordering/slippage.
- Rounding can cause a depositor to receive fewer shares than expected; integrations should enforce user-defined minimums and maximums at their own transaction boundary.
- This assumes a conventional non-rebasing ERC-20. A pausable, blacklisting, fee-on-transfer, rebasing, or malicious token changes the risk model.
- Shares are transferable ERC-20 tokens. Anyone holding them can redeem their share of assets.
- The mock's unrestricted mint lets test accounts simulate deposits and donations; it is not an access-control model.

## Study questions

1. Why does the vault mint shares instead of recording fixed asset balances?
2. What is the difference between `convertToShares` and `previewDeposit`?
3. Why do `previewWithdraw` and `previewMint` round in the opposite direction from `previewDeposit` and `previewRedeem`?
4. How does an asset donation affect the share price and later depositors?
5. Why is this **not** a production yield vault even when tests pass?
