# Study guide: ERC-4626 vault

Work through this before making the repository public. The vault uses OpenZeppelin's standard implementation; the custom code only adds a fixed precision offset and a donation function.

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

Add a test that records `previewDeposit` before and after a donation, and checks that a later depositor receives fewer shares for the same assets. State the assumption under which the comparison is valid.

## 5. Readiness check

Explain why this is only a yield **simulation**: it has no strategy, no source of profit, no slippage controls at the caller boundary, and no audit. Do not claim that successful unit tests prove safety with real funds.
