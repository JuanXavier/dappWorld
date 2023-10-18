// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

enum GameStatus {
  Inactive,
  Active
}

contract ParchiThap {
  address private immutable OWNER = msg.sender;
  GameStatus private gameStatus;
  uint88 private startTime;
  uint8 private playerInTurnIndex;
  address[4] private players;
  uint8[4][4] private gameState;
  mapping(address => uint256) private wins;

  function _onlyOwner() private view {
    if (msg.sender != OWNER) revert();
  }

  function _onlyInStatus(GameStatus _gameStatus) private view {
    if (gameStatus != _gameStatus) revert();
  }

  function _isPlayer(address player) private view returns (bool b) {
    unchecked {
      for (uint256 i; i < 4; ++i) {
        b = player == players[i];
        if (b) break;
      }
    }
  }

  function _addPlayers(address[4] memory _players) public {
    unchecked {
      if (
        _players[0] == _players[1] ||
        _players[0] == _players[2] ||
        _players[0] == _players[3] ||
        _players[1] == _players[2] ||
        _players[1] == _players[3] ||
        _players[2] == _players[3]
      ) revert();
      for (uint256 i; i < 4; ++i) {
        if (_players[i] == address(0) || _players[i] == msg.sender) revert();
        players[i] = _players[i];
      }
    }
  }

  function _getIndex() private view returns (uint256 index) {
    unchecked {
      for (uint256 i; i < 4; ++i) {
        if (players[i] == msg.sender) {
          index = i;
          break;
        }
      }
    }
  }

  // player 1 should always have 4
  /** this should pass[[1,1,0,1],[0,0,4,1],[2,1,0,1],[1,2,0,1]]) */
  /** this should fail [[2,1,1,1],[0,1,1,1],[1,1,1,1],[1,1,1,1]]) */
  function _setState(uint8[4][4] memory _state) public {
    unchecked {
      uint256 total;
      for (uint256 i; i < 4; ++i) {
        // horizontal
        total = _state[i][0] + _state[i][1] + _state[i][2] + _state[i][3];
        if (total < 3 || total > 5) revert();
        // vertical
        total = _state[0][i] + _state[1][i] + _state[2][i] + _state[3][i];
        if (total != 4) revert();
      }
      gameState = _state;
      gameStatus = GameStatus.Active;

      startTime = uint88(block.timestamp);
    }
  }

  function _newGameState() private view returns (uint8[4][4] memory _parchis) {
    uint256 pos;
    uint256 rand = uint256(keccak256(abi.encodePacked(block.timestamp)));
    uint256 i;
    uint[4] memory z;

    unchecked {
      while (i < 16) {
        if (((rand >> pos) & 1) == 1) {
          uint a = pos % 4;
          while (z[a] == 4) a = ++a % 4;
          ++_parchis[a][i / 4];
          ++z[a];
          ++i;
        }
        ++pos;
      }
    }
  }

  function _resetGame() private {
    playerInTurnIndex = 0;
    delete players;
    delete gameState;
    gameStatus = GameStatus.Inactive;
  }

  /* ****************************************************** */
  /*                        EXTERNAL                        */
  /* ****************************************************** */

  function startGame(address p1, address p2, address p3, address p4) external {
    _onlyOwner();
    _onlyInStatus(GameStatus.Inactive);
    _addPlayers([p1, p2, p3, p4]);
    _setState(_newGameState());
  }

  function setState(address[4] calldata _players, uint8[4][4] calldata _state) external {
    _onlyOwner();
    _onlyInStatus(GameStatus.Inactive);
    _addPlayers(_players);
    _setState(_state);
  }

  function passParchi(uint8 _type) external {
    uint8 _playerInTurnIndex = playerInTurnIndex;
    if (msg.sender != players[_playerInTurnIndex]) revert();
    uint8 nextPlayerInTurnIndex = (++_playerInTurnIndex) % 4;

    if (gameState[playerInTurnIndex][_type - 1] > 0) {
      gameState[playerInTurnIndex][_type - 1] -= 1;
      gameState[nextPlayerInTurnIndex][_type - 1] += 1;
    } else revert();

    playerInTurnIndex = nextPlayerInTurnIndex;
  }

  function claimWin() external {
    unchecked {
      if (!_isPlayer(msg.sender)) revert();
      _onlyInStatus(GameStatus.Active);
      uint256 playerIndex = _getIndex();

      uint256 i = 4;
      while (i > 0) {
        if (gameState[playerIndex][i - 1] == 4) {
          _resetGame();
          ++wins[msg.sender];
          return;
        }
        --i;
      }
      revert();
    }
  }

  function endGame() external {
    if (!_isPlayer(msg.sender)) revert();
    if (block.timestamp < startTime + 1 hours) revert();
    _resetGame();
  }

  function getWins(address player) external view returns (uint256) {
    if (player == address(0) || player == OWNER) revert();
    return wins[player];
  }

  function myParchis() external view returns (uint8[4] memory) {
    unchecked {
      if (!_isPlayer(msg.sender)) revert();
      uint256 index = _getIndex();
      return gameState[index];
    }
  }

  function getState() external view returns (address[4] memory, address turn, uint8[4][4] memory) {
    _onlyOwner();
    _onlyInStatus(GameStatus.Active);
    return (players, players[playerInTurnIndex], gameState);
  }
}

// 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
// 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db
// 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB
// 0x617F2E2fD72FD9D5503197092aC168c91465E7f2
// ["0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2","0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db","0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB","0x617F2E2fD72FD9D5503197092aC168c91465E7f2"]
// [[1,1,0,1],[0,0,4,1],[2,1,0,1],[1,2,0,1]]
