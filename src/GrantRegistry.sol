// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { IGrantRegistry } from "./interfaces/IGrantRegistry.sol";

/// @title Grant Registry
/// @author KarmaGap | 0xneves.eth
/// @notice Registry of the grant applications issued by grant programs.
contract GrantRegistry is IGrantRegistry {
  /// Map the grant ID to the grant data
  mapping(bytes32 => Grant) private _grants;

  /// Map the grant ID to its grant manager
  mapping(bytes32 => address) private _managers;

  /// @notice Register a new grant in the registry
  /// @param grant The grant struct to be registered
  /// @param manager The address allowed to perform operations on the grant
  function register(Grant calldata grant, address manager) public returns (bytes32) {
    // generate the grant ID and verify if it already exists
    bytes32 grantId = generateId(grant);
    if (_grants[grantId].network != 0) revert GrantAlreadyExists();

    // store the grant data and its manager address
    _managers[grantId] = manager;
    _grants[grantId] = grant;

    // emit an event and return the grant ID
    emit GrantRegistered(grantId, manager);
    return grantId;
  }

  /// @notice Update the grant data
  /// @param grantId The grant ID to be updated
  /// @param grant The new grant data
  function update(bytes32 grantId, Grant calldata grant) public {
    _verify(grantId);
    _grants[grantId] = grant;
    emit GrantUpdated(grantId, grant.status);
  }

  /// @notice Remove a grant from the registry
  /// @param grantId The grant ID to be removed
  function remove(bytes32 grantId) public {
    _verify(grantId);
    delete _grants[grantId];
    emit GrantDeleted(grantId);
  }

  /// @notice Transfer the ownership of a grant to a new address
  /// @param grantId The grant ID to be transferred
  /// @param newManager The new manager address
  function transferOwnership(bytes32 grantId, address newManager) public {
    _verify(grantId);
    _managers[grantId] = newManager;
    emit GrantManagerChanged(grantId, msg.sender, newManager);
  }

  /// @notice Verify if the grant exists and the sender is the grant manager
  function _verify(bytes32 _grantId) internal view {
    // checks if the grant exists
    if (_grants[_grantId].network == 0) revert GrantNonExistant();
    // checks if the sender is the grant manager
    if (_managers[_grantId] != msg.sender) revert InvalidGrantManager();
  }

  /// @notice Get the grant data struct
  /// @param grantId The grant ID to be retrieved
  function getGrant(bytes32 grantId) public view returns (Grant memory) {
    return _grants[grantId];
  }

  /// @notice Get the manager address of a grant
  /// @param grantId The grant ID to get the manager address
  function getManager(bytes32 grantId) public view returns (address) {
    return _managers[grantId];
  }

  /// @notice Generate a unique ID from a grant first state
  /// @param grant The grant struct to generate the ID from
  function generateId(Grant calldata grant) public pure returns (bytes32) {
    return keccak256(abi.encode(grant));
  }
}
