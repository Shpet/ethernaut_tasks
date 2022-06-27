// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TimeLock {
    uint256 constant MIN_DELAY = 30 seconds;
    uint256 constant MAX_DELAY = 365 days;

    address immutable owner;

    string public message;

    uint256 public amount;

    mapping(bytes32 => bool) public queue;

    modifier onlyOwner() {
        require(owner == msg.sender, "Timelock. Modifier. Not an owner");
        _;
    }
    modifier timestampIsValid(uint256 _timestamp) {
        require(
            _timestamp > block.timestamp + MIN_DELAY &&
                _timestamp < block.timestamp + MAX_DELAY,
            "Timelock. Modifier timestampIsValid. Invalid timestamp"
        );
        _;
    }

    event Queued(
        address _to,
        string _funcName,
        bytes _data,
        uint256 _value,
        uint256 _timestamp
    );
    event Discarded(bytes32 _txId);
    event Executed(bytes32 txId);

    constructor() {
        owner = msg.sender;
    }

    function demo(string calldata _message) external payable {
        message = _message;
        amount = msg.value;
    }

    function getNextTimestamp() external view returns (uint256 timestamp) {
        timestamp = block.timestamp + 42 days;
    }

    function preparedData(string calldata _message) external pure returns(bytes memory){
        return abi.encode(_message);
    }

    function addToQueue(
        address _to,
        string calldata _funcName,
        bytes calldata _data,
        uint256 _value,
        uint256 _timestamp
    ) external onlyOwner timestampIsValid(_timestamp) returns (bytes32) {
        bytes32 txId = calcTxId(_to, _funcName, _data, _value, _timestamp);

        require(!queue[txId], "Timelock. AddToQueue. Already in queue");

        queue[txId] = true;

        emit Queued(_to, _funcName, _data, _value, _timestamp);

        return txId;
    }

    function discard(bytes32 _txId) external onlyOwner {
        require(queue[_txId], "Timelock. Discard. Not an queued");

        delete queue[_txId];

        emit Discarded(_txId);
    }

    function execute(
        address _to,
        string calldata _funcName,
        bytes calldata _data,
        uint256 _value,
        uint256 _timestamp
    )
        external
        payable
        onlyOwner
        timestampIsValid(_timestamp)
        returns (bytes memory)
    {
        bytes32 txId = calcTxId(_to, _funcName, _data, _value, _timestamp);
        bytes memory data;

        delete (queue[txId]);

        if (bytes(_funcName).length > 0) {
            data = abi.encodePacked(bytes4(keccak256(bytes(_funcName))), _data);
        } else {
            data = _data;
        }

        (bool success, bytes memory resp) = _to.call{value: _value}(data);

        require(success, "Timelock. Execute. Call failed");

        emit Executed(txId);

        return resp;
    }

    function calcTxId(
        address _to,
        string calldata _funcName,
        bytes calldata _data,
        uint256 _value,
        uint256 _timestamp
    ) public pure returns (bytes32 hashId) {
        hashId = keccak256(
            abi.encode(_to, _funcName, _data, _value, _timestamp)
        );
    }
}
