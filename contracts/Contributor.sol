// SPDX-License-Identifier: Apache-2.0

import "@rmrk-team/evm-contracts/contracts/RMRK/nestable/RMRKNestable.sol";

pragma solidity ^0.8.16;

contract Contributor is RMRKNestable{
    uint256 private tokenCounter;
    address contributorRecipient;
    uint256 recipientNft_ID; // we need to get this data from somewhere

    constructor(
        string memory name,
        string memory symbol
    )
        RMRKNestable(name, symbol)
    {
        // Custom optional: constructor logic
        tokenCounter = 1;
    }

   // mapp issuers of cred with category they issued cred for, so we can reject duplicate minting.
    mapping(address issuer => mapping(uint256 contributorCategoryId => bool haveCred)) public issuerToContributor;

    // minting reputation NFT as nested NFT
    function giveContributor(uint256 contributorCategoryId) public returns (uint256) {
        
        // needs gatekeeping logic, only someone with profile NFT can give cred
        //require(msg.sender has profileNFT, "");

        // check if issuer already gave reputation with same category ID
        bool currentContributor = issuerToContributor[msg.sender][contributorCategoryId];
        require(!currentContributor);

        // TODO: destinationId - parent token ID, aka credRecipient profile NFT id
        _nestMint(contributorRecipient, tokenCounter, recipientNft_ID, '0x0');
        unchecked {tokenCounter++;}
        //emit event instead of return
        // cred is minted, add flag true
        currentContributor = true;
        return tokenCounter;
    }


    function getTokenCounter() public view returns (uint256) {
        return tokenCounter;
    }
}