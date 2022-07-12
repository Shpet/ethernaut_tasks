// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MultiSig {
    uint256 public immutable REQUIRED_CONFIRMATIONS;

    uint256 amount;

    string message;

    address[] owners;

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        uint256 confirmations;
        uint256 createdAt;
    }

    mapping(address => bool) isOwner;
    mapping(bytes32 => Transaction) public txs;
    mapping(bytes32 => mapping(address => bool)) public confirmations;

    modifier onlyOwner() {
        require(isOwner[msg.sender], "MultiSig: not an owner!");
        _;
    }

    event AddedTx(bytes32 txId);
    event Executed(bytes32 txId);
    event Confirmed(bytes32 txId, address from);
    event Unconfirmed(bytes32 txId, address from);

    constructor(uint256 required_confirmations_, address[] memory owners_) {
        REQUIRED_CONFIRMATIONS = required_confirmations_;

        require(
            owners_.length >= required_confirmations_,
            "MultiSig: not enough owners"
        );

        for (uint256 i; i < owners_.length; i++) {
            require(
                owners_[i] != address(0),
                "MultiSig: owner can't be a zero address"
            );
            require(!isOwner[owners_[i]], "MultiSig: duplicate owners!");

            isOwner[owners_[i]] = true;
            owners.push(owners_[i]);
        }
    }

    function demo(string calldata msg_) external payable {
        message = msg_;
        amount = msg.value;
    }

    function prepareData(string calldata _msg)
        external
        pure
        returns (bytes memory)
    {
        return abi.encode(_msg);
    }

    function addTx(
        address to_,
        string calldata func_,
        bytes calldata data_,
        uint256 value_
    ) external onlyOwner returns (bytes32) {
        uint256 created = block.timestamp;
        bytes32 txId = calcTxId(to_, func_, data_, value_, created);

        txs[txId] = Transaction({
            to: to_,
            value: value_,
            data: data_,
            confirmations: 0,
            createdAt: created
        });

        emit AddedTx(txId);

        return txId;
    }

    function confirm(bytes32 txId_) external onlyOwner {
        require(txs[txId_].createdAt > 0, "MultiSig: tx is not exist");
        require(!confirmations[txId_][msg.sender], "already confirmed!");

        txs[txId_].confirmations++;
        confirmations[txId_][msg.sender] = true;
    }

    function cancelConfirmation(bytes32 txId_) external onlyOwner {
        require(txs[txId_].createdAt > 0, "MultiSig: tx is not exist");
        require(confirmations[txId_][msg.sender], "MultiSig: not confirmed!");

        txs[txId_].confirmations--;
        confirmations[txId_][msg.sender] = false;
    }

    function execute(bytes32 txId_, string calldata func_)
        external
        payable
        onlyOwner
        returns (bytes memory)
    {
        require(txs[txId_].createdAt > 0, "MultiSig: tx is not exist");

        require(
            txs[txId_].confirmations >= REQUIRED_CONFIRMATIONS,
            "not enough confirmations!"
        );

        bytes memory data;
        if (bytes(func_).length > 0) {
            data = abi.encodePacked(
                bytes4(keccak256(bytes(func_))),
                txs[txId_].data
            );
        } else {
            data = txs[txId_].data;
        }

        (bool success, bytes memory resp) = txs[txId_].to.call{
            value: txs[txId_].value
        }(data);

        delete txs[txId_];

        require(success);

        emit Executed(txId_);
        return resp;
    }

    function calcTxId(
        address to_,
        string calldata funcName_,
        bytes calldata data_,
        uint256 value_,
        uint256 createdAt_
    ) public pure returns (bytes32 hashId) {
        hashId = keccak256(
            abi.encode(to_, funcName_, data_, value_, createdAt_)
        );
    }
}
