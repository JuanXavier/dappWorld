// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LotteryPool {
  address private immutable OWNER = msg.sender;
  uint256 private totalFeesCollected;
  address private lastWinner;
  uint8 private lock = 1;
  address[] private players;
  uint256[] private amountsPaid;
  mapping(address => uint256) private gamesWon;

  function _getIndex(address player) private view returns (uint256) {
    unchecked {
      uint256 i = players.length;
      for (; i > 0; --i) if (players[i - 1] == player) return i - 1;
      return 4;
    }
  }

  function _removePlayer(uint256 index) private {
    unchecked {
      for (; index < players.length - 1; ++index) {
        players[index] = players[index + 1];
        amountsPaid[index] = amountsPaid[index + 1];
      }
      players.pop();
      amountsPaid.pop();
    }
  }

  function _pickWinner() private {
    unchecked {
      uint256 random = uint256(keccak256(abi.encodePacked(block.timestamp))) % 5;
      address winner;
      if (random == 4) winner = msg.sender;
      else winner = players[random];
      lastWinner = winner;
      ++gamesWon[winner];
      (bool ok, ) = winner.call{value: address(this).balance}("");
      if (!ok) revert();
      delete players;
      delete amountsPaid;
    }
  }

  function enter() external payable {
    unchecked {
      if (
        msg.sender == OWNER || _getIndex(msg.sender) < 4 || msg.value != 0.1 ether + (gamesWon[msg.sender] * 0.01 ether)
      ) revert();
      uint256 fee = (msg.value * 10 ether) / 100 ether;
      (bool ok, ) = OWNER.call{value: fee}("");
      if (!ok) revert();
      totalFeesCollected += fee;
      if (players.length == 4) _pickWinner();
      else {
        players.push(msg.sender);
        amountsPaid.push(msg.value - fee);
      }
    }
  }

  function withdraw() external {
    unchecked {
      uint256 index = _getIndex(msg.sender);
      if (index == 4 || lock == 2) revert();
      lock = 2;
      (bool ok, ) = msg.sender.call{value: amountsPaid[index]}("");
      if (!ok) revert();
      _removePlayer(index);
      lock = 1;
    }
  }

  function viewParticipants() external view returns (address[] memory, uint256) {
    return (players, players.length);
  }

  function viewPreviousWinner() external view returns (address) {
    if (lastWinner == address(0)) revert();
    return lastWinner;
  }

  function viewEarnings() external view returns (uint256) {
    if (msg.sender != OWNER) revert();
    return totalFeesCollected;
  }

  function viewPoolBalance() external view returns (uint256) {
    return address(this).balance;
  }
}
