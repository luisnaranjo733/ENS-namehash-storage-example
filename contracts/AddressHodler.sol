//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

// This contract is deployed at 0xa746B0D0E24d3863c9194cF14eAd8eD22dAF4f75 on Rinkeby

interface ENS {
    function resolver(bytes32 node) external view returns (Resolver);
}

interface Resolver {
    function addr(bytes32 node) external view returns (address);
}

/// @title Address Hodler
/// @author Luis Naranjo
/// @notice Address holder contract for demo purposes (how to store ENS names and Ethereum addresses in the same array)
contract AddressHodler {

    bytes32[] private addresses;

    // Add an address to storage
    // Can be an ENS node (namehash) or an Ethereum address (right padded with zeros to fill the last 12 bytes)
    function addAddress(bytes32 _bytes) public {
        addresses.push(_bytes);
    }

    // Retrieve the bytes32 at a particular index in our storage array
    function getBytes(uint _index) public view returns (bytes32) {
        return addresses[_index];
    }

    // Given a bytes32, determine if it is an ethereum address
    // Assume that bytes32 with the last 12 bytes being null = ethereum address
    // NOTICE: not necessarily a secure/safe assumption to make. A malicious actor may be able to manipulate this
    // and convince this function that an ethereum address is actually an ENS node
    function areBytesEthereumAddress(bytes32 _bytes) public pure returns (bool) {
        // If the any of the last 12 bytes are NOT null, we can assume it's NOT an ethereum address
        // There is surely a more gas efficient bit operation we could do here to achieve the same goal
        for (uint i = 20; i < 32; i++) {
            if (_bytes[i] != 0) {
                return false;
            }
        }
        return true;
    }

    // Internal helper fn that can cast a bytes32 that is expected to be an address
    // to an actuall Solidity address type
    function bytesToAddress(bytes32 _bytes) public pure returns (address) {
        // Convert 32 byte data into a 20 byte address by explicitly truncating the last 12 (assumed) null bytes
        return address(uint160(bytes20(_bytes)));
    }

    // Resolve an ENS node namehash to an Ethereum address
    function resolve(bytes32 _node) public view returns(address) {
        ENS ens = ENS(0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e);
        Resolver resolver = ens.resolver(_node);
        return resolver.addr(_node);
    }

    // Fetch the Ethereum address at the bytes32 at addresses[_index]
    // Doesn't matter if the target address is an ENS node or an Ethereum address
    // This function will convert to an address either way
    function getAddress(uint _index) public view returns (address) {
        bytes32 _bytes = getBytes(_index);
        if (areBytesEthereumAddress(_bytes)) {
            return bytesToAddress(_bytes);
        }
        return resolve(_bytes);
    }
}
