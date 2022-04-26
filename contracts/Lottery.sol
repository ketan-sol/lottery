// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

contract Lottery {
    address public owner;
    address payable[] public players;
    uint256 public lotteryId;
    mapping(uint256 => address payable) public history;

    constructor() {
        owner = msg.sender;
        lotteryId = 1;
    }

    function getWinnerByLottery(uint256 id)
        public
        view
        returns (address payable)
    {
        return history[id];
    }

    function entry() public payable {
        require(msg.value > 0.01 ether, "entry fee cannot be 0");
        players.push(payable(msg.sender));
    }

    function getRandomNumber() public view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(owner, block.timestamp)));
    }

    function getWinner() public onlyOwner {
        uint256 index = getRandomNumber() % players.length;
        players[index].transfer(address(this).balance);
        history[lotteryId] = players[index];

        //to avoid rentrancy issue, any state to be updated should be updated after transfer function
        lotteryId++;

        //reset contract after winner is picked
        players = new address payable[](0);
    }

    function getPotBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getPlayers() public view returns (address payable[] memory) {
        return players;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can pick winner");
        _;
    }
}
