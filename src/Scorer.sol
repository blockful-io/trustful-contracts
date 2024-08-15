// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { IScorerResolver } from "./interfaces/IScorerResolver.sol";

/// @title Scorer
/// @author KarmaGap | 0xneves.eth
contract Scorer {
  mapping(bytes32 => address) private _resolvers;

  function registerResolver(bytes32 scorerId, address resolver) public {
    _resolvers[scorerId] = resolver;
  }

  function registerScorer() public returns (bytes32) {}
}
