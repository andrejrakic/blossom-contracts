// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.16;

import "@rmrk-team/evm-contracts/contracts/RMRK/nestable/RMRKNestable.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {Ownable} from "./utils/Ownable.sol";
// import {ENS, Resolver} from "./utils/ENS.sol";


contract Profile is RMRKNestable, Ownable {
    struct ReputationRecords {
        bool isActive; 
        string reputationName;
    }

    struct ProfileDetails {
        uint256 parentId;
        bytes32 twitterUidHash;
        bool isOrg;
        string ensHandle;
        mapping(uint256 reputationTokenId => ReputationRecords) selfRep;
    }

   //  address constant ENS_ADDRESS = 0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e;

    bytes32 internal merkleRoot;
    uint256 internal tokenId;
    address internal immutable reputationContractAddress;
   //  ENS internal ens;

    mapping(address organization => ProfileDetails profileDetails) public profiles;
    mapping(bytes32 twitterUidHash => bool exists) internal twitterUidHashes;

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
        bytes32 _merkleRoot,
        address _reputationContractAddress
    ) RMRKNestable(name, symbol) Ownable(multisigOwner, address(0)) {
        merkleRoot = _merkleRoot;
        reputationContractAddress = _reputationContractAddress;
       //  ens = ENS(ENS_ADDRESS);
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

       // bytes32 ensNode = computeNamehash(ensHandle);
       // Resolver resolver = ens.resolver(ensNode);
       // address ensAddress = resolver.addr(ensNode);

        // if(msg.sender != ensAddress) {
        //   revert EnsAddressMissmatch();
        // }

        if(twitterUidHashes[twitterUidHash]) {
          revert TwitterProfileAlreadyConnected(twitterUidHash);
        }

        profiles[msg.sender].parentId = tokenId;
        profiles[msg.sender].twitterUidHash = twitterUidHash;
        profiles[msg.sender].ensHandle = ensHandle;

        _safeMint(msg.sender, tokenId, "0x0");

        unchecked {
            tokenId++;
        }

        emit ProfileCreated(msg.sender, tokenId);
    }

    function displayReputationInProfile(uint256 childIndex, uint256 childId) public {
        acceptChild(profiles[msg.sender].parentId, childIndex, reputationContractAddress, childId);
    }

    function hideReputationFromProfile(uint256 reputationTokenId) external {
        profiles[msg.sender].selfRep[reputationTokenId].isActive = false;
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

    // // helper function
    // function computeNamehash(string memory name) public pure returns (bytes32 namehash) {
    //     namehash = 0x0000000000000000000000000000000000000000000000000000000000000000;
    //     namehash = keccak256(abi.encodePacked(namehash, keccak256(abi.encodePacked("eth"))));
    //     namehash = keccak256(abi.encodePacked(namehash, keccak256(abi.encodePacked(name))));
    // }

    // helper function
    // Today, Twitter IDs are unique 64-bit unsigned integers,
    function hashTwitterUid(uint64 twitterUid) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(twitterUid));
    }

    function _beforeNestedTokenTransfer(
        address from,
        address to,
        uint256 fromTokenId,
        uint256 toTokenId,
        uint256 tokenId,
        bytes memory data
    ) internal pure override {
        require(from == address(0) || to == address(0), "Soulbound token");
    }

    // ovo isto treba i za _beforeBurn da se preventuje burning
}
