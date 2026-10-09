# Threat model

## Assets and actors

Depositors exchange underlying ERC-20 assets for transferable vault shares. Shareholders can withdraw or redeem their proportional asset claim. A donor may add tokens without receiving shares. The underlying token issuer may control token behavior.

## Important assumptions

The vault uses OpenZeppelin Contracts v5.6.1 ERC-4626 accounting. The asset is assumed to be a conventional, non-rebasing ERC-20 with reliable `transfer`, `transferFrom`, `balanceOf`, and decimals. There is no strategy and no external yield source.

## Risks

| Risk | Mitigation or limit |
| --- | --- |
| Empty-vault donation / inflation | OpenZeppelin virtual assets/shares plus six-decimal offset raise attack cost; still test your own integration and deposit sizes. |
| Rounding and slippage | ERC-4626 specifies preview rounding, but direct standard methods have no caller-provided slippage limits. Integrators should enforce them. |
| Token freeze or pause | Token operations can fail and block exits. Not controlled by the vault. |
| Token rebase or transfer fee | Unsupported; share/accounting assumptions can break. |
| Share transfer | Shares are transferable; whoever owns shares can redeem them. |
| Malicious underlying token | Outside this educational model; callbacks and dishonest balances require a different design and review. |
| Yield claim | There is no investment strategy. Donations only simulate external profit. |

No audit or production deployment has been performed.
