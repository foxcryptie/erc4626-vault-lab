# Study guide: ERC-4626 vault

The vault uses OpenZeppelin's standard implementation; the custom code only adds a fixed precision offset and a donation function. Use this guide to check whether you understand the share math.

## 1. Trace shares and assets

Follow `testDepositAndRedeem` and `testDonationRaisesShareValue`. Write down total assets, total shares, Alice's shares, and `convertToAssets(Alice's shares)` before and after the donation. Explain why donating assets does not mint shares.

## 2. Read the standard

Read the linked EIP-4626 and OpenZeppelin guide. In your own words, distinguish:

- `deposit` from `mint`;
- `withdraw` from `redeem`;
- `convertToShares` from `previewDeposit`;
- `previewWithdraw` from `previewRedeem`.

## 3. Study rounding and inflation

Explain the first-deposit inflation attack and what virtual shares/assets plus a six-decimal offset change. Run the small-deposit-after-donation test, then vary the donation amount and observe the share output.

## 4. Make a change yourself

Write a test showing that `previewMint` requires more assets after a donation for the same number of shares. Then explain why a caller should enforce a maximum asset amount when minting.

## 5. Readiness check

Explain why this is only a yield **simulation**: it has no strategy, no source of profit, no slippage controls at the caller boundary, and no audit. Do not claim that successful unit tests prove safety with real funds.
