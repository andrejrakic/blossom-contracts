// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.16;

import "@rmrk-team/evm-contracts/contracts/RMRK/nestable/RMRKNestable.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {Ownable} from "./utils/Ownable.sol";
import {ENS, Resolver} from "./utils/ENS.sol";


// TODO: whenNotPaused modifier

contract Profile is RMRKNestable, Ownable {
    struct ProfileDetails {
        bytes32 twitterUidHash;
        bool isOrg; // false by default
        string ensHandle;
        uint256[] selfRep;
    }

    address constant ENS_ADDRESS = 0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e;

    bytes32 internal merkleRoot;
    uint256 internal tokenId;
    ENS internal ens;

    mapping(address organization => ProfileDetails profileDetails) public profiles;
    mapping(bytes32 twitterUidHash => bool exists) public twitterUidHashes;

    event MerkleRootUpdated(bytes32 merkleRoot);
    event ProfileCreated(address indexed owner, uint256 indexed tokenId);
    event OrganizationApproved(uint256 indexed profileId);

    error InvalidOrganization(address organization);
    error ProfileAlreadyExists(address organization);
    error EnsAddressMissmatch();
    error TwitterProfileAlreadyConnected(bytes32 twitterUidHash);

    constructor(
        string memory name,
        string memory symbol,
        address multisigOwner,
        bytes32 _merkleRoot
    ) RMRKNestable(name, symbol) Ownable(multisigOwner, address(0)) {
        merkleRoot = _merkleRoot;
        ens = ENS(ENS_ADDRESS);
        tokenId = 1;  // Id cannot be zero, because of https://github.com/rmrk-team/evm/blob/dev/contracts/RMRK/nestable/RMRKNestable.sol#LL512-L512C56
    }

    function createProfile(
        bytes32 twitterUidHash,
        string memory ensHandle,
        bytes32 whitelistedOrgLeaf,
        bytes32[] memory proof
    ) external {
        if (!MerkleProof.verify(proof, merkleRoot, whitelistedOrgLeaf))
            revert InvalidOrganization(msg.sender);
 
        if(profiles[msg.sender].twitterUidHash != 0x0) {
            revert ProfileAlreadyExists(msg.sender);
        }

        bytes32 ensNode = computeNamehash(ensHandle);
        Resolver resolver = ens.resolver(ensNode);
        address ensAddress = resolver.addr(ensNode);

        if(msg.sender != ensAddress) {
          revert EnsAddressMissmatch();
        }

        if(twitterUidHashes[twitterUidHash]) {
          revert TwitterProfileAlreadyConnected(twitterUidHash);
        }

        profiles[msg.sender] = ProfileDetails({
            twitterUidHash: twitterUidHash,
            isOrg: false,
            ensHandle: ensHandle,
            selfRep: new uint256[](0)
        });

        _safeMint(msg.sender, tokenId, "0x0");

        unchecked {
            tokenId++;
        }

        emit ProfileCreated(msg.sender, tokenId);
    }

    function approveOrganization(uint256 profileId) external onlyOwner {
      (address directOwner,,) = directOwnerOf(profileId);

      profiles[directOwner].isOrg = true;

      emit OrganizationApproved(profileId);
    }

    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;

        emit MerkleRootUpdated(_merkleRoot);
    }

    // helper function
    function computeNamehash(string memory name) public pure returns (bytes32 namehash) {
        namehash = 0x0000000000000000000000000000000000000000000000000000000000000000;
        namehash = keccak256(abi.encodePacked(namehash, keccak256(abi.encodePacked("eth"))));
        namehash = keccak256(abi.encodePacked(namehash, keccak256(abi.encodePacked(name))));
    }

    // helper function
    // Today, Twitter IDs are unique 64-bit unsigned integers,
    function hashTwitterUid(uint64 twitterUid) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(twitterUid));
    }
}
