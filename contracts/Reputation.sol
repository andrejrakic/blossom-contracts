// SPDX-License-Identifier: Apache-2.0

import "@rmrk-team/evm-contracts/contracts/RMRK/nestable/RMRKNestable.sol";

pragma solidity ^0.8.16;

// gatekeeping
// optional emits
// categories logic
// optional comment from issuer

contract Reputation is RMRKNestable {
    uint256 private tokenCounter;
    address credRecipient;
    uint256 recipientNft_ID; // we need to get this data from somewhere

    /* 
    =====================================
    Things we wanna have in ReputationNFT
    =====================================
        issuerNFT_ID - id of profile nft that gave cred
        parentNFT_ID - id of profile NFT that gets cred
        categoryId - id of category this person is getting cred for
        (optional) categoryTitle
        string comment - comment related to the reputation, better to store on ipfs
    */

    struct Cred {
        uint256 credTokenId;
        uint256 issuerNft_ID;
        uint256 parentNft_ID;
        uint256 categoryId;
        // ???
    }

    // mapp issuers of cred with category they issued cred for, so we can reject duplicate minting.
    mapping(address issuer => mapping(uint256 categoryId => bool haveCred)) public issuerToCred;

    // TODO
    string public constant TOKEN_URI =
        "ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=0-PUG.json";

    constructor(
        string memory name,
        string memory symbol
    )
        RMRKNestable(name, symbol)
    {
        // Custom optional: constructor logic
        tokenCounter = 1;
    }

    // minting reputation NFT as nested NFT
    function giveCred(uint256 categoryId) public returns (uint256) {
        
        // needs gatekeeping logic, only someone with profile NFT can give cred
        //require(msg.sender has profileNFT, "");

        // check if issuer already gave reputation with same category ID
        bool currentCred = issuerToCred[msg.sender][categoryId];
        require(!currentCred);

        // TODO: destinationId - parent token ID, aka credRecipient profile NFT id
        _nestMint(credRecipient, tokenCounter, recipientNft_ID, '0x0');
        unchecked {tokenCounter++;}
        //emit event instead of return
        // cred is minted, add flag true
        currentCred = true;
        return tokenCounter;
    }


    function getTokenCounter() public view returns (uint256) {
        return tokenCounter;
    }
}