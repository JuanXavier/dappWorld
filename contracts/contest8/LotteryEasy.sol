// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LotteryEasy {
  address[] private players;
  address lastWinner;

  function _getIndex(address player) private view returns (uint256) {
    unchecked {
      uint256 i = players.length;
      for (; i > 0; --i) if (players[i - 1] == player) return i - 1;
      return 4;
    }
  }

  function _pickWinner() private {
    unchecked {
      uint256 random = uint256(keccak256(abi.encodePacked(block.timestamp))) % 5;
      address winner;
      if (random == 4) winner = msg.sender;
      else winner = players[random];
      lastWinner = winner;
      (bool ok, ) = winner.call{value: address(this).balance}("");
      if (!ok) revert();
      delete players;
    }
  }

  function enter() external payable {
    unchecked {
      if (_getIndex(msg.sender) < 4 || msg.value != 0.1 ether) revert();
      if (players.length == 4) _pickWinner();
      else players.push(msg.sender);
    }
  }

  function viewParticipants() external view returns (address[] memory, uint256) {
    return (players, players.length);
  }

  function viewPreviousWinner() external view returns (address) {
    if (lastWinner == address(0)) revert();
    return lastWinner;
  }
}
