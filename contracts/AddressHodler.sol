//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

/// @title Address Hodler
/// @author Luis Naranjo
/// @notice Address holder contract for demo purposes (how to store ENS names and Ethereum addresses in the same array)
contract AddressHodler {
    bytes32[] private addresses;

    function addAddress(bytes32 _bytes) public {
        addresses.push(_bytes);
    }

    function areBytesEthereumAddress(bytes32 _bytes) public pure returns (bool) {
        // // If the any of the last 12 bytes are NOT null, we can assume it's NOT an ethereum address
        for (uint i = 20; i < 32; i++) {
            if (_bytes[i] != 0) {
                return false;
            }
        }
        return true;
    }

    function getBytes(uint _index) public view returns (bytes32) {
        return addresses[_index];
    }

    function getAddress(uint _index) public view returns (address) {
        return address(uint160(bytes20(getBytes(_index))));
    }
}
