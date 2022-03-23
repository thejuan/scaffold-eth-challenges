// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
    ExampleExternalContract public exampleExternalContract;
    mapping(address => uint256) public balances;
    event Stake(address indexed sender, uint256 balance);
    uint256 public constant threshold = 1 ether;
    uint256 public deadline = block.timestamp + 30 seconds;
    bool public completed = false;

    constructor(address exampleExternalContractAddress) {
        exampleExternalContract = ExampleExternalContract(
            exampleExternalContractAddress
        );
    }

    //  Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
    //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
    function stake() public payable {
        require(!completed, "Contract completed");
        balances[msg.sender] = balances[msg.sender] + msg.value;
        emit Stake(msg.sender, balances[msg.sender]);
    }

    // After some `deadline` allow anyone to call an `execute()` function
    //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
    // if the `threshold` was not met, allow everyone to call a `withdraw()` function
    function execute() public payable {
        require(timeLeft() <= 0, "Deadline not reached");
        if (address(this).balance >= threshold) {
            exampleExternalContract.complete{value: address(this).balance}();
        }
        completed = true;
    }

    // Add a `withdraw(address payable)` function lets users withdraw their balance
    function withdraw(address to) public {
        require(completed, "Not Completed, call execute");
        require(address(this).balance < threshold, "Threshold reached");

        (bool sent, bytes memory data) = to.call{value: balances[msg.sender]}(
            ""
        );
        require(sent, "Failed to send Ether");
    }

    // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend.
    function timeLeft() public view returns (uint256) {
        if (block.timestamp >= deadline) {
            return 0;
        }

        return deadline - block.timestamp;
    }

    // Add the `receive()` special function that receives eth and calls stake()
    receive() external payable {
        stake();
    }
}
