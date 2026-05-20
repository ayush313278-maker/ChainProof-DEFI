// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ChainProof {

    // Admin address
    address public admin;

    // Credential structure
    struct Credential {
        string title;
        uint level;
        uint timestamp;
    }

    // Store credentials
    mapping(address => Credential[]) private credentials;

    // Prevent duplicate credentials
    mapping(address => mapping(string => bool)) private hasCredential;

    constructor() {
        admin = msg.sender;
    }

    // Only admin modifier
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can issue");
        _;
    }

    // Issue credential
    function issueCredential(
        address user,
        string memory title,
        uint level
    ) public onlyAdmin {

        require(level >= 1 && level <= 3, "Level must be 1-3");

        // Reject duplicate titles
        require(
            !hasCredential[user][title],
            "Credential already exists"
        );

        credentials[user].push(
            Credential(title, level, block.timestamp)
        );

        hasCredential[user][title] = true;
    }

    // Get credentials
    function getCredentials(address user)
        public
        view
        returns (Credential[] memory)
    {
        return credentials[user];
    }

    /*
    Trust Score Formula:
    Level 1 = 10
    Level 2 = 20
    Level 3 = 30

    Higher level credentials give
    more trust score.
    */

    function calculateTrustScore(address user)
        public
        view
        returns (uint)
    {
        uint score = 0;

        for (uint i = 0; i < credentials[user].length; i++) {

            if (credentials[user][i].level == 1) {
                score += 10;
            }

            else if (credentials[user][i].level == 2) {
                score += 20;
            }

            else if (credentials[user][i].level == 3) {
                score += 30;
            }
        }

        return score;
    }

    /*
    Non-transferability:
    No transfer function exists.

    Credentials remain permanently
    attached to the issued wallet.
    */

    function accessGranted()
        public
        view
        returns (bool)
    {
        uint trustScore = calculateTrustScore(msg.sender);

        require(
            trustScore >= 30,
            "Access denied: low trust score"
        );

        return true;
    }
}