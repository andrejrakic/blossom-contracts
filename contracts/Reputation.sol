// SPDX-License-Identifier: Apache-2.0

import "@rmrk-team/evm-contracts/contracts/RMRK/nestable/RMRKNestable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

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
    mapping(address issuer => mapping(string categoryId => bool haveCred)) internal issuerToCred;
    mapping(uint256 tokenId => string tokenUri) internal tokenUris;

    // // TODO
    // string public constant TOKEN_URI =
    //     "ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=0-PUG.json";

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
    function giveCred(string memory categoryId) public returns (uint256) {
        
        // needs gatekeeping logic, only someone with profile NFT can give cred
        //require(msg.sender has profileNFT, "");

        // check if issuer already gave reputation with same category ID
        bool currentCred = issuerToCred[msg.sender][categoryId];
        require(!currentCred);

        // TODO: destinationId - parent token ID, aka credRecipient profile NFT id
        _nestMint(credRecipient, tokenCounter, recipientNft_ID, '0x0');

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                    '{"name": "',
                    categoryId,
                    '", "description": "Blossoms", "image": "https://ipfs.io/ipfs/QmSsYRx3LpDAb1GZQm7zZ1AuHZjfbPkD6J7s9r41xu1mf8?filename=pug.png"}'
                    )
                )
            )
        );

        string memory tokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        tokenUris[tokenCounter] = tokenUri;

        unchecked {tokenCounter++;}
        //emit event instead of return
        // cred is minted, add flag true
        currentCred = true;
        return tokenCounter;
    }


    function getTokenUri(uint256 tokenId) public view returns (string memory) {
        return tokenUris[tokenId];
    }
}