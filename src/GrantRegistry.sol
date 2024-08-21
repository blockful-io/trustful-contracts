// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { IGrantRegistry } from "./interfaces/IGrantRegistry.sol";

/// @title Grant Registry
/// @author KarmaGap | 0xneves.eth
/// @notice Register and maintain a list of grants issued by grant programs.
contract GrantRegistry is IGrantRegistry {
  /// Map the grant ID to the grant data
  mapping(bytes32 => Grant) private _grants;

  /// Map the grant ID to its grant manager
  mapping(bytes32 => address) private _managers;

  /// @dev Register a new grant in the registry
  /// @param _grant The grant struct to be registered
  /// @param _manager The address allowed to perform operations on the grant
  function register(Grant calldata _grant, address _manager) public {
    // generate the grant ID and verify if it already exists
    bytes32 grantId = generateId(_grant);
    if (_grants[grantId].network != 0) revert GrantAlreadyExists();

    // store the grant data and its manager address
    _managers[grantId] = _manager;
    _grants[grantId] = _grant;
    emit GrantRegistered(grantId, _manager);
  }

  /// @dev Update the grant data
  /// @param grantId The grant ID to be updated
  /// @param _grant The new grant data
  function update(bytes32 grantId, Grant calldata _grant) public {
    _verify(grantId);
    _grants[grantId] = _grant;
    emit GrantUpdated(grantId, _grant.status);
  }

  /// @dev Remove a grant from the registry
  /// @param grantId The grant ID to be removed
  function remove(bytes32 grantId) public {
    _verify(grantId);
    delete _grants[grantId];
    emit GrantDeleted(grantId);
  }

  /// @dev Transfer the ownership of a grant to a new address
  /// @param grantId The grant ID to be transferred
  /// @param newManager The new manager address
  function transferOwnership(bytes32 grantId, address newManager) public {
    _verify(grantId);
    _managers[grantId] = newManager;
    emit GrantManagerChanged(grantId, msg.sender, newManager);
  }

  /// @dev Verify if the grant exists and the sender is the grant manager
  function _verify(bytes32 grantId) internal view {
    // checks if the grant exists
    if (_grants[grantId].network == 0) revert GrantNonExistant();
    // checks if the sender is the grant manager
    if (_managers[grantId] != msg.sender) revert InvalidGrantManager();
  }

  /// @dev Get the grant data struct
  /// @param grantId The grant ID to be retrieved
  function grant(bytes32 grantId) public view returns (Grant memory) {
    return _grants[grantId];
  }

  /// @dev Get the manager address of a grant
  /// @param grantId The grant ID to get the manager address
  function manager(bytes32 grantId) public view returns (address) {
    return _managers[grantId];
  }

  /// @dev Generate a unique ID from a grant first state
  /// @param _grant The grant struct to generate the ID from
  function generateId(Grant calldata _grant) public pure returns (bytes32) {
    return keccak256(abi.encode(_grant));
  }
}
