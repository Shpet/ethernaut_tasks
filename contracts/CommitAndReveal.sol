// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CommitAndReveal {
    //   ethers.utils.formatBytes32String('secretWord') => 0x736563726574576f726400000000000000000000000000000000000000000000
    //   ethers.utils.solidityKeccak256(['address', 'bytes32', 'address'],['0x90F79bf6EB2c4f870365E785982E1f101E93b906', '0x736563726574576f726400000000000000000000000000000000000000000000', '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266'])

    address _owner;

    address[] public candidats = [
        0x90F79bf6EB2c4f870365E785982E1f101E93b906,
        0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC,
        0x70997970C51812dc3A010C7d01b50e0d17dc79C8
    ];

    mapping(address => bytes32) _commits;
    mapping(address => uint256) votes;

    bool public votingStopped;

    modifier onlyOwner() {
        require(_owner == msg.sender, "CommitAndReveal: not an owner!");
        _;
    }

    constructor() {
        _owner = msg.sender;
    }

    // 0x4da3d29693e9e02158df6883619bb321ee934c33de83528a19e73fc47cdbfed5
    function commitVote(bytes32 hash_) external {
        require(!votingStopped, "CommitAndReveal: voting is stopped");
        require(
            _commits[msg.sender] == bytes32(0),
            "CommitAndReveal: already voted"
        );

        _commits[msg.sender] = hash_;
    }

    function revealVote(address candidate_, bytes32 secretWord_) external {
        require(votingStopped, "CommitAndReveal: voting is not stopped");

        bytes32 commit = keccak256(
            abi.encodePacked(candidate_, secretWord_, msg.sender)
        );

        require(
            commit == _commits[msg.sender],
            "CommitAndReveal: incorrect data"
        );

        delete _commits[msg.sender];

        votes[candidate_]++;
    }

    function stopVoting() external onlyOwner {
        votingStopped = true;
    }
}
