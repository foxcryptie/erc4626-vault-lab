// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @notice ERC-4626 vault lab. Donors add assets to simulate yield; there is no investment strategy.
/// @dev The six-decimal share offset reduces first-deposit rounding/inflation risk.
contract DonationYieldVault is ERC4626 {
    using SafeERC20 for IERC20;

    error ZeroAmount();
    error UnsupportedTokenBehavior();

    constructor(IERC20 asset_) ERC20("Donation Yield Vault Share", "dyvUSDC") ERC4626(asset_) {}

    function _decimalsOffset() internal pure override returns (uint8) {
        return 6;
    }

    /// @notice Add external assets without minting shares. This models yield for tests.
    function donateYield(uint256 assets) external {
        if (assets == 0) revert ZeroAmount();
        IERC20 underlying = IERC20(asset());
        uint256 beforeBalance = underlying.balanceOf(address(this));
        underlying.safeTransferFrom(msg.sender, address(this), assets);
        uint256 afterBalance = underlying.balanceOf(address(this));
        if (afterBalance < beforeBalance || afterBalance - beforeBalance != assets) {
            revert UnsupportedTokenBehavior();
        }
    }
}
