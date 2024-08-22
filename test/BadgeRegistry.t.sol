// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { Test, console2 } from "forge-std/src/Test.sol";
import { BadgeRegistry, IBadgeRegistry } from "../src/BadgeRegistry.sol";

contract TestBadgeRegistry is Test {
  BadgeRegistry public registry;

  address Bianco = 0xF977814e90dA44bFA03b6295A0616a897441aceC;

  function setUp() public {
    registry = new BadgeRegistry();
  }

  function test_badge_register() public {
    bytes32 badgeId = registerBadge();
    IBadgeRegistry.Badge memory registeredBadge = registry.getBadge(badgeId);
    assertEq(registeredBadge.name, "Ethereum");
    assertEq(registeredBadge.description, "Ethereum badge Yiupi");
    assertEq(registeredBadge.metadata, "https://example.com/eg.png");
    assertEq(registeredBadge.data, "0x");
  }

  function test_badge_register_duplicate() public {
    IBadgeRegistry.Badge memory badge = IBadgeRegistry.Badge({
      name: "Ethereum",
      description: "Ethereum badge Yiupi",
      metadata: "https://example.com/eg.png",
      data: "0x"
    });
    registry.create(badge);

    try registry.create(badge) {
      revert("Should have reverted");
    } catch {
      this;
    }
  }

  function registerBadge() public returns (bytes32) {
    IBadgeRegistry.Badge memory badge = IBadgeRegistry.Badge({
      name: "Ethereum",
      description: "Ethereum badge Yiupi",
      metadata: "https://example.com/eg.png",
      data: "0x"
    });

    return registry.create(badge);
  }
}
