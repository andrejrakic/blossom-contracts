// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

abstract contract Resolver {
    function addr(bytes32 node) public view virtual returns (address);
}
