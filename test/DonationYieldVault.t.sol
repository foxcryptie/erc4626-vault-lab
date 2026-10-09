// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {DonationYieldVault} from "../src/DonationYieldVault.sol";
import {MockUSDC} from "./MockUSDC.sol";

contract DonationYieldVaultTest is Test {
    MockUSDC internal usdc;
    DonationYieldVault internal vault;
    address internal alice = makeAddr("alice");
    address internal bob = makeAddr("bob");
    address internal donor = makeAddr("donor");

    function setUp() public {
        usdc = new MockUSDC();
        vault = new DonationYieldVault(IERC20(address(usdc)));
        usdc.mint(alice, 1_000_000_000);
        usdc.mint(bob, 1_000_000_000);
        usdc.mint(donor, 1_000_000_000);
        vm.prank(alice);
        usdc.approve(address(vault), type(uint256).max);
        vm.prank(bob);
        usdc.approve(address(vault), type(uint256).max);
        vm.prank(donor);
        usdc.approve(address(vault), type(uint256).max);
    }

    function testDepositAndRedeem() public {
        uint256 expectedShares = vault.previewDeposit(100_000_000);
        vm.prank(alice);
        uint256 shares = vault.deposit(100_000_000, alice);
        assertEq(shares, expectedShares);
        assertEq(vault.balanceOf(alice), shares);
        assertEq(vault.totalAssets(), 100_000_000);

        uint256 preview = vault.previewRedeem(shares);
        vm.prank(alice);
        uint256 assets = vault.redeem(shares, alice, alice);
        assertEq(assets, preview);
        assertEq(vault.balanceOf(alice), 0);
        assertEq(usdc.balanceOf(alice), 1_000_000_000);
    }

    function testDonationRaisesShareValue() public {
        vm.prank(alice);
        uint256 shares = vault.deposit(100_000_000, alice);
        vm.prank(donor);
        vault.donateYield(20_000_000);
        assertEq(vault.totalAssets(), 120_000_000);
        assertGt(vault.convertToAssets(shares), 100_000_000);
        assertLe(vault.convertToAssets(shares), 120_000_000);
        vm.prank(alice);
        uint256 assets = vault.redeem(shares, alice, alice);
        assertGt(assets, 100_000_000);
    }

    function testDonationChangesNextDepositorsPreview() public {
        vm.prank(alice);
        vault.deposit(100_000_000, alice);
        uint256 beforeDonation = vault.previewDeposit(10_000_000);
        vm.prank(donor);
        vault.donateYield(20_000_000);
        uint256 afterDonation = vault.previewDeposit(10_000_000);
        assertLt(afterDonation, beforeDonation);
        vm.prank(bob);
        uint256 actualShares = vault.deposit(10_000_000, bob);
        assertEq(actualShares, afterDonation);
    }

    function testCannotRedeemAnotherOwnersSharesWithoutAllowance() public {
        vm.prank(alice);
        uint256 shares = vault.deposit(100_000_000, alice);
        vm.prank(bob);
        vm.expectRevert();
        vault.redeem(shares, bob, alice);
    }

    function testPreviewWithdrawMatchesBurnedShares() public {
        vm.prank(alice);
        vault.deposit(100_000_000, alice);
        vm.prank(donor);
        vault.donateYield(20_000_000);
        uint256 expectedShares = vault.previewWithdraw(10_000_000);
        vm.prank(alice);
        uint256 burnedShares = vault.withdraw(10_000_000, alice, alice);
        assertEq(burnedShares, expectedShares);
        assertEq(vault.totalAssets(), usdc.balanceOf(address(vault)));
    }

    function testSmallDepositAfterDonationStillMintsShares() public {
        vm.prank(alice);
        vault.deposit(1, alice);
        vm.prank(donor);
        vault.donateYield(1_000_000);
        vm.prank(bob);
        uint256 shares = vault.deposit(1_000, bob);
        assertGt(shares, 0);
    }

    function testZeroDonationReverts() public {
        vm.prank(donor);
        vm.expectRevert(DonationYieldVault.ZeroAmount.selector);
        vault.donateYield(0);
    }

    function testFuzzImmediateRoundTripDoesNotCreateAssets(uint96 rawAmount) public {
        uint256 amount = bound(uint256(rawAmount), 1, 1_000_000_000);
        uint256 startBalance = usdc.balanceOf(alice);
        vm.prank(alice);
        uint256 shares = vault.deposit(amount, alice);
        vm.prank(alice);
        uint256 returned = vault.redeem(shares, alice, alice);
        assertLe(returned, amount);
        assertLe(usdc.balanceOf(alice), startBalance);
        assertEq(vault.totalAssets(), usdc.balanceOf(address(vault)));
    }
}
