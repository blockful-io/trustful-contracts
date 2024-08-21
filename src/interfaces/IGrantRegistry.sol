// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

interface IGrantRegistry {
  error GrantAlreadyExists();
  error GrantNonExistant();
  error InvalidGrantManager();

  event GrantRegistered(bytes32 indexed grantId, address indexed manager);
  event GrantUpdated(bytes32 indexed grantId, Status status);
  event GrantDeleted(bytes32 indexed grantId);
  event GrantManagerChanged(
    bytes32 indexed grantId,
    address indexed oldManager,
    address indexed newManager
  );

  struct Grant {
    uint256 network; // Blockchain network where the grant is being developed
    address grantee; // Address of the person responsible for delivering and receiving the grant reward
    string protocol; // Name of the protocol/community that issued the grant
    string project; // Name/Title of the project or company that received the grant
    string[] externalLinks; // Link that redirects to the grant proposal, discussion or relative
    uint256 startDate; // Start date for the grant development
    uint256 endDate; // Expected completion date for the grant
    Status status; // Current status of the grant
    Disbursement disbursements; // Disbursement stages based on milestones
  }

  enum Status {
    Proposed, // The grant has been proposed but not yet approved (Default)
    InProgress, // The project is actively being worked on
    Completed, // The project has been completed and deliverables submitted
    Cancelled, // The grant was cancelled
    Rejected // The grant proposal was reviewed and rejected
  }

  struct Disbursement {
    address[] fundingTokens; // Tokens that will be disbursed in this stage
    uint256[] fundingAmounts; // Amounts of tokens to be disbursed in this stage
    bool[] disbursed; // Indicates if the disbursement has been made in this stage
  }
}
