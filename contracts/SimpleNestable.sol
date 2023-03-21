// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.16;

import "@rmrk-team/evm-contracts/contracts/RMRK/nestable/RMRKNestable.sol";

contract AdvancedNestable is RMRKNestable {
    // NOTE: Additional custom arguments can be added to the constructor based on your needs.
    constructor(string memory name, string memory symbol)
        RMRKNestable(name, symbol)
    {
        // Custom optional: constructor logic
    }
}
