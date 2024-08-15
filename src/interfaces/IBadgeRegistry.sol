// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

interface IBadgeRegistry {
  error BadgeAlreadyRegistered();

  event BadgeRegistered(bytes32 indexed badgeId, address indexed issuer, string name);

  struct Badge {
    string name;
    string description;
    string metadata;
    bytes data;
  }
}
