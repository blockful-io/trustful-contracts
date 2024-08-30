// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { Test, console2 } from "forge-std/src/Test.sol";
import { GrantRegistry, IGrantRegistry } from "../src/GrantRegistry.sol";

contract TestGrantRegistry is Test {
  GrantRegistry public registry;

  address Bianco = 0xF977814e90dA44bFA03b6295A0616a897441aceC;

  function setUp() public {
    registry = new GrantRegistry();
  }

  function test_grant_registration() public {
    registerGrant();
  }

  function test_grant_removal() public {
    bytes32 grantId = registerGrant();
    vm.prank(Bianco);
    registry.remove(grantId);
  }

  function test_grant_removal_not_manager() public {
    bytes32 grantId = registerGrant();
    vm.prank(address(0x007));
    try registry.remove(grantId) {
      revert("Not pranking manager");
    } catch {
      this;
    }
  }

  function test_grant_removal_invalid_grantid() public {
    bytes32 grantId = bytes32(uint256(7));
    try registry.remove(grantId) {
      revert("Should have reverted");
    } catch {
      this;
    }
  }

  function test_grant_update() public {
    bytes32 grantId = registerGrant();
    IGrantRegistry.Grant memory grant = registry.getGrant(grantId);
    grant.status = IGrantRegistry.Status.InProgress;
    vm.prank(Bianco);
    registry.update(grantId, grant);
  }

  function test_grant_transfer_ownership() public {
    bytes32 grantId = registerGrant();
    vm.prank(Bianco);
    registry.transferOwnership(grantId, address(0x7));
  }

  function test_grant_transfer_ownership_not_manager() public {
    bytes32 grantId = registerGrant();
    vm.prank(address(0x007));
    try registry.transferOwnership(grantId, address(0x7)) {
      revert("Should have reverted");
    } catch {
      this;
    }
  }

  function registerGrant() public returns (bytes32) {
    // Simulating a funding disbursement in different milestones
    // 1st milestone: 3e18 of token weth
    // 1st milestone: 5e18 of token weth
    // 2st milestone: 10_000e6 of token usdc
    // 2st milestone: 20_000e6 of token usdc
    address[] memory fundingTokens = new address[](4);
    fundingTokens[0] = address(0x1);
    fundingTokens[1] = address(0x2);
    fundingTokens[2] = address(0x1);
    fundingTokens[3] = address(0x2);
    uint256[] memory fundingAmounts = new uint256[](4);
    fundingAmounts[0] = 3e18;
    fundingAmounts[1] = 10_000e6;
    fundingAmounts[2] = 5e18;
    fundingAmounts[3] = 20_000e6;

    // The disbursed array is initialized with the same length as the fundingTokens array
    // and it will always be full of false values expected to turn true when the milestone is completed
    IGrantRegistry.Disbursement memory disbursements = IGrantRegistry.Disbursement({
      fundingTokens: fundingTokens,
      fundingAmounts: fundingAmounts,
      disbursed: new bool[](fundingTokens.length)
    });

    // Preparing the grant struct in the Arbitrum chain
    GrantRegistry.Grant memory grant = IGrantRegistry.Grant({
      id: bytes32(0),
      chain: block.chainid,
      grantee: address(0x5),
      grantProgramLabel: "Test",
      project: "Test",
      externalLinks: new string[](0),
      startDate: block.timestamp,
      endDate: block.timestamp + 1 days,
      status: IGrantRegistry.Status.Proposed,
      disbursements: disbursements
    });

    // Registering the grant
    registry.register(grant, Bianco);

    // Checking if the grant was registered
    bytes32 grantId = registry.generateId(grant);
    assertEq(registry.getGrant(grantId).chain, block.chainid);
    assertEq(registry.getGrant(grantId).grantee, address(0x5));

    return grantId;
  }
}
