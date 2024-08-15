// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

/// @notice This contract is used to resolve attestations from EAS.
/// The implementer should create a custom logic to fetch badges and attestations from EAS that
/// don't follow the same standard, creating backwards compatibility with the Scorer.
interface IScorerResolver is IBadge {
  struct Badge {
    string name;
    string description;
    string metadata;
    bytes data;
  }

  function resolveEAS(bytes32 uid, bytes memory data) external view returns (Badge memory);
}
