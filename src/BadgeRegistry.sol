// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { IBadgeRegistry } from "./interfaces/IBadgeRegistry.sol";

/// @title Badge Registry
/// @author KarmaGap | 0xneves.eth
contract BadgeRegistry is IBadgeRegistry {
  /// Map of badges registered in the registry
  mapping(bytes32 => Badge) public badges;

  /// @notice Registers a badge in the registry
  /// @param badge Badge data struct
  function create(Badge calldata badge) public returns (bytes32) {
    bytes32 badgeId = generateId(badge);
    if (bytes(badges[badgeId].name).length > 0) revert BadgeAlreadyRegistered();

    badges[badgeId] = badge;
    emit BadgeRegistered(badgeId, msg.sender, badge.name);
    return badgeId;
  }

  /// @notice Gets a badge from the registry
  function getBadge(bytes32 badgeId) public view returns (Badge memory) {
    return badges[badgeId];
  }

  /// @notice Generates a badge ID
  /// @param badge Badge data struct
  function generateId(Badge calldata badge) public pure returns (bytes32) {
    return keccak256(abi.encode(badge));
  }
}
