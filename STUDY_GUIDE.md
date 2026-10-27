# Follow the shares

The local contract is short: OpenZeppelin handles ERC-4626 deposits and withdrawals, while [`DonationYieldVault.sol`](src/DonationYieldVault.sol) adds a six-decimal offset and `donateYield`.

Start with `testDonationRaisesShareValue` in [`test/DonationYieldVault.t.sol`](test/DonationYieldVault.t.sol). Write down `totalAssets`, total share supply, Alice's share balance, and the asset value of those shares after each step:

1. Alice deposits 100 mock-token units.
2. A donor transfers 20 units through `donateYield`.
3. Alice redeems her shares.

The donation creates no shares. That is why the value represented by each existing share rises. The virtual asset and share terms in OpenZeppelin's implementation affect the exact amount Alice can redeem, so check the test values instead of assuming she receives all 120.

Next, compare `previewDeposit(10_000_000)` before and after the donation in `testDonationChangesNextDepositorsPreview`. Then change the donation amount and rerun `forge test --match-test testDonationChangesNextDepositorsPreview -vv`. Which direction does the later depositor's share quote move?

Finally, read `testSmallDepositAfterDonationStillMintsShares` and the immediate round-trip fuzz test. They check particular rounding cases; they do not prove safety for arbitrary tokens or integrations. A caller who needs a minimum number of shares must enforce that at its own transaction boundary.
