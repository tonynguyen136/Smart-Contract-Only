// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Lottery{
    // declearing the state variables
    address payable[] public players; // dynamic array of type address payable
    address public manager;

    constructor(){
        // initializing the owner to the address that deploys the contract
        manager = msg.sender;
    }
    receive() payable external{
        // each player sends exactly 0.1 ETH
        require(msg.value == 0.1 ether);
        // appendig the player to the players array
        players.push(payable(msg.sender));
    }
    function getBalance() public view returns(uint){
        // only the manager is allowed to call it
        require(msg.sender == manager);
        return address(this).balance;
    }
    function random() internal view returns(uint){
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
    }
    function pickWinner() public{
        // only the manager can pick a winner if there are at least 3 players in the lottery
        require(msg.sender == manager);
        require(players.length >= 3);

        uint r = random();
        address payable winner;

        // computting a random index of the array
        uint index = r % players.length;
        winner = players[index]; // this is the winner
        // transferring the entire contract's balance to the winner
        winner.transfer(getBalance());
        // resetting the loterry for the next round
        players = new address payable[](0);
    }
}