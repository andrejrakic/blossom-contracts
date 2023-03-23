// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import {Resolver} from "./Resolver.sol";

abstract contract ENS {
    function resolver(bytes32 node) public view virtual returns (Resolver);
}
