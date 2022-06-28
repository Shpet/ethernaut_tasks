// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EncodeDiffer {
    // "text", "ext" => "tex", "text" = is not same
    function encode(string calldata str1, string calldata str2)
        external
        pure
        returns (bytes memory)
    {
        return abi.encode(str1, str2);
    }

    // "text", "ext" => "tex", "text" = same
    function encodePacked(string calldata str1, string calldata str2)
        external
        pure
        returns (bytes memory)
    {
        return abi.encodePacked(str1, str2);
    }

    // "text", "ext" => "tex", "text" = same
    function collision(string calldata str1, string calldata str2)
        external
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(str1, str2));
    }
}
