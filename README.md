# ERC-4626 Vault Lab

[![Foundry CI](https://github.com/foxcryptie/erc4626-vault-lab/actions/workflows/ci.yml/badge.svg)](https://github.com/foxcryptie/erc4626-vault-lab/actions/workflows/ci.yml)

This lab asks one question: what happens to vault shares when assets arrive without new shares being minted?

[`DonationYieldVault.sol`](src/DonationYieldVault.sol) uses OpenZeppelin's ERC-4626 implementation. Its own additions are a six-decimal offset and `donateYield`, which transfers tokens into the vault without issuing shares. The function is a way to test the accounting; it is not a yield strategy.

In `testDonationRaisesShareValue`, Alice deposits 100 units of the mock token, then a donor adds 20. Alice still owns the same number of shares, but those shares now represent more assets. `testDonationChangesNextDepositorsPreview` checks the other side of that change: a later depositor gets a different share quote. The tests also cover redemption, preview rounding, small deposits after a donation, and an immediate round trip that cannot create assets.

## Run it

Install [Foundry](https://book.getfoundry.sh/getting-started/installation) and Git. The repository uses OpenZeppelin Contracts `v5.6.1` and forge-std `v1.17.0`:

```bash
mkdir -p lib
git clone --depth 1 --branch v5.6.1 https://github.com/OpenZeppelin/openzeppelin-contracts.git lib/openzeppelin-contracts
git clone --depth 1 --branch v1.17.0 https://github.com/foundry-rs/forge-std.git lib/forge-std
forge build
forge test -vv
```

Read [`test/DonationYieldVault.t.sol`](test/DonationYieldVault.t.sol) beside the contract. [`STUDY_GUIDE.md`](STUDY_GUIDE.md) traces the share math, and [`THREAT_MODEL.md`](THREAT_MODEL.md) records the token assumptions. The [ERC-4626 specification](https://eips.ethereum.org/EIPS/eip-4626) and [OpenZeppelin's guide](https://docs.openzeppelin.com/contracts/5.x/erc4626) explain the rounding and inflation-attack background.

This is an accounting exercise with a mintable mock token. It has no strategy, oracle, fees, or external source of returns. The offset reduces some first-deposit inflation risk but does not make every deposit safe. There has been no audit; do not put real funds into it.
