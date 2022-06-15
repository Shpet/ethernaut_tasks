// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MemoryAndCalldata {
    function memoryTest(string memory _str) public pure returns(bytes32 data){
        assembly{
            // Space for memory data
            let ptr := mload(64)

            // Reading memory data
            data := mload(sub(ptr, 32))
        }
    }


    //calldata is immutable and cheaper 
    function calldataTest (string calldata _str) public pure returns(bytes32 data){
        assembly{
            // first 4 bytes it's function selector
            let countOfBytesToInfo := calldataload(4)

            let infoAboutSize := calldataload(add(4, countOfBytesToInfo))


            // Reading calldata. 32bytes for info about size
            data := calldataload(add(4, add(countOfBytesToInfo, 32)))
        }
    }
}