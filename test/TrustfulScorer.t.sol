// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { Test, console2 } from "forge-std/src/Test.sol";
import { TrustfulScorer, ITrustfulScorer } from "../src/TrustfulScorer.sol";

contract TestGrantRegistry is Test {
  TrustfulScorer public scorer;

  address Bianco = 0xF977814e90dA44bFA03b6295A0616a897441aceC;

  function setUp() public {
    vm.label(Bianco, "Bianco");
    scorer = new TrustfulScorer();
  }

  function test_scorer_register() public {
    bytes32[] memory badgeIds = new bytes32[](7);
    uint256[] memory badgeScores = new uint256[](7);

    badgeIds[0] = 0xe02b7f93d209aa1a9708544eb17e46eee3a1f45fed0de720f4866e0caff148f8;
    badgeIds[1] = 0x446d8276789167189130fb83fce2c7b401752249a46b7e001d517c972a680219;
    badgeIds[2] = 0xb2cf2baa9cdf459fd115c1bac872e0c7318c71d1201da034ff34090bf5c9ead3;
    badgeIds[3] = 0xe85f17539b1c37dce80ab28bd08ca41f0c3f04a997756426157561ccf3447efa;
    badgeIds[4] = 0x8934465c22520a1367b2794d7c3448e531923564a89acf65fc1cb97d918eb9bd;
    badgeIds[5] = 0xc7110d04cc11dd911b5c12d4a26449fd87d7b6bf92ffbe02d0cda65b161eacb9;
    badgeIds[6] = 0x41fdc7e77ebf77189b683427e0c79506b9177b5ddad561f8e1d62b15f779dcfb;

    badgeScores[0] = 1;
    badgeScores[1] = 2;
    badgeScores[2] = 3;
    badgeScores[3] = 4;
    badgeScores[4] = 5;
    badgeScores[5] = 4;
    badgeScores[6] = 3;

    vm.startPrank(Bianco);

    // Register Scorer
    uint256 scorerId = scorer.registerScorer(Bianco, address(this), badgeIds, badgeScores, 18, "");
    address manager = scorer.getManagerAddress(scorerId);
    assert(manager == Bianco);

    // Add and Remove Badges
    bytes32 newBadge = 0x41fdc7e77ebf77189b683427e0c79506b9177b5ddad561f8e1d62b15f779dcfa;
    scorer.addBadgeToScorer(scorerId, newBadge, 5);
    scorer.removeBadgeFromScorer(scorerId, newBadge);
    assert(scorer.scorerContainsBadge(scorerId, newBadge) == false);

    // Add, then remove badge of address in the scorer
    scorer.registerBadgeToAddr(Bianco, scorerId, badgeIds[0]);
    bytes32[] memory values = scorer.getBadgesFromAddr(Bianco, scorerId);
    assert(values.length == 1);
    assert(values[0] == badgeIds[0]);
    scorer.removeBadgeFromAddr(Bianco, scorerId, badgeIds[0]);
    values = scorer.getBadgesFromAddr(Bianco, scorerId);
    assert(values.length == 0);

    // Add all badges to the user and get their legacy score
    for (uint256 i = 0; i < badgeIds.length; i++) {
      scorer.registerBadgeToAddr(Bianco, scorerId, badgeIds[i]);
    }
    (
      bytes32[] memory badgesIds,
      uint256[] memory scoresIds,
      uint256 finalScore,
      uint256 averageScore
    ) = scorer.getLegacyScoreOf(Bianco, scorerId);

    assert(finalScore == 22 * 1e18);
    console2.log("Final Score: %s", finalScore);
    console2.log("Average Score: %s", averageScore);
    console2.log("badgeIds Length: %s", badgesIds.length);
    console2.log("scoresIds Length: %s", scoresIds.length);

    // Update Resolver
    address newResolver = Bianco;
    scorer.setNewResolver(scorerId, newResolver);
    address resolver = scorer.getResolverAddress(scorerId);
    assert(resolver == newResolver);

    // Update Manager
    address newManager = address(this);
    scorer.setNewManager(scorerId, newManager);
    manager = scorer.getManagerAddress(scorerId);
    assert(manager == newManager);

    // Get Badges Ids
    bytes32[] memory badges = scorer.getBadgeIds(scorerId);
    assert(badges[0] == badgeIds[0]);
    assert(badges[1] == badgeIds[1]);
    assert(badges[2] == badgeIds[2]);
    assert(badges[3] == badgeIds[3]);
    assert(badges[4] == badgeIds[4]);
    assert(badges[5] == badgeIds[5]);
    assert(badges[6] == badgeIds[6]);

    // Get Scores Decimals
    uint8 decimals = scorer.getScorerDecimals(scorerId);

    // Get Badges Scores
    uint256[] memory scores = scorer.getBadgesScores(scorerId);
    console2.log("Scores: %s", badgeScores[0] * 10 ** decimals);
    assert(scores[0] == badgeScores[0] * 10 ** decimals);
    assert(scores[1] == badgeScores[1] * 10 ** decimals);
    assert(scores[2] == badgeScores[2] * 10 ** decimals);
    assert(scores[3] == badgeScores[3] * 10 ** decimals);
    assert(scores[4] == badgeScores[4] * 10 ** decimals);
    assert(scores[5] == badgeScores[5] * 10 ** decimals);
    assert(scores[6] == badgeScores[6] * 10 ** decimals);

    // Get Badge Score
    uint256 badgeScore = scorer.getBadgeScore(scorerId, badgeIds[0]);
    assert(badgeScore == badgeScores[0] * 10 ** decimals);

    // Scorer Contains Badge
    bool contains = scorer.scorerContainsBadge(scorerId, badgeIds[0]);
    assert(contains == true);
  }
}
