// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

enum GameStatus {
  Inactive,
  Active
}

contract ParchiThap {
  GameStatus internal gameStatus;
  address private immutable OWNER;
  uint88 internal startTime;
  uint8 playerInTurnIndex;

  address[4] public players;
  uint8[4][4] public gameState;

  mapping(address => uint256) private wins;

  function _onlyOwner() private view {
    if (msg.sender != OWNER) revert();
  }

  function _onlyInStatus(GameStatus _gameStatus) private view {
    if (gameStatus != _gameStatus) revert();
  }

  constructor() {
    OWNER = msg.sender;
  }

  function _addPlayers(address[4] memory _players) private {
    unchecked {
      uint256 i = 4;
      while (i > 0) {
        if (players[i] != address(0) && players[i] != msg.sender) players[i] = _players[i];
        else revert();
        --i;
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

  function _setState(uint8[4][4] memory _state) private pure {
    unchecked {
      uint256 total;
      for (uint256 i; i < 4; ++i) {
        total = _state[i][0] + _state[i][1] + _state[i][2] + _state[i][3];
        if (total != 4) revert();
        total = _state[0][i] + _state[1][i] + _state[2][i] + _state[3][i];
        if (total != 4) revert();
      }
    }
  }

  function _newGameState() public view returns (uint8[4][4] memory _parchis) {
    uint256 pos;
    uint256 rand = uint256(keccak256(abi.encodePacked(block.timestamp)));
    uint256 i;
    uint[4] memory z;

    unchecked {
      while (i < 16) {
        // i 0, rand 1234
        if (((rand >> pos) & 1) == 1) {
          uint a = pos % 4; // the whole loop would go {0,0,0,0,1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4}
          while (z[a] == 4) a = ++a % 4; // if value is 4, change is to a value between 0 and 3
          ++_parchis[a][i / 4]; // update horizontal values 0
          ++z[a];
          ++i;
        }
        ++pos;
      }
    }
  }

  /* ****************************************************** */
  /*                        EXTERNAL                        */
  /* ****************************************************** */

  function startGame(address p1, address p2, address p3, address p4) external {
    if (p1 == p2 || p1 == p3 || p1 == p4) revert();
    _onlyOwner();
    _onlyInStatus(GameStatus.Inactive);

    address[4] memory _players = [p1, p2, p3, p4];
    _addPlayers(_players);

    gameStatus = GameStatus.Active;
    players = _players;
    startTime = uint88(block.timestamp);

    _setState(_newGameState());
  }

  function setState(address[4] calldata _players, uint8[4][4] calldata _state) external {
    _onlyOwner();
    _onlyInStatus(GameStatus.Inactive);
    _addPlayers(_players);
    _setState(_state);
  }

  function passParchi(uint8 _type) external {
    unchecked {
      uint8 _playerInTurnIndex = playerInTurnIndex;
      if (msg.sender != players[_playerInTurnIndex]) revert();

      uint8[4] memory playerParchis = gameState[_playerInTurnIndex];

      uint8 nextPlayerInTurnIndex = (++_playerInTurnIndex) % 4;

      if (playerParchis[_type] > 0) {
        --gameState[_playerInTurnIndex][_type];
        ++gameState[nextPlayerInTurnIndex][_type];
      } else revert();

      playerInTurnIndex = nextPlayerInTurnIndex;
    }
  }

  function endGame() public {
    if (!isPlayer(msg.sender)) revert();
    if (block.timestamp < startTime + 1 hours) revert();
    _resetGame();
  }

  function claimWin() external {
    unchecked {
      if (!isPlayer(msg.sender)) revert();
      _onlyInStatus(GameStatus.Active);
      uint256 playerIndex = _getIndex();
      uint256 i = 4;
      while (i > 0) {
        if (gameState[playerIndex][i] == 4) {
          _resetGame();
          ++wins[msg.sender];
          return;
        }
      }
      revert();
    }
  }

  function isPlayer(address player) internal view returns (bool b) {
    unchecked {
      uint256 i = 4;

      while (i > 0) {
        b = player == players[i];
        --i;
      }
    }
  }

  function _resetGame() internal {
    playerInTurnIndex = 0;
    delete players;
    delete gameState;
    gameStatus = GameStatus.Inactive;
  }

  function getState() external view returns (address[4] memory, address turn, uint8[4][4] memory) {
    _onlyOwner();
    _onlyInStatus(GameStatus.Active);
    return (players, players[playerInTurnIndex], gameState);
  }

  function getWins(address player) external view returns (uint256) {
    return wins[player];
  }

  function myParchis() external view returns (uint8[4] memory) {
    unchecked {
      if (!isPlayer(msg.sender)) revert();
      uint256 index = _getIndex();
      return gameState[index];
    }
  }
}
// 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
// 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db
// 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB
// 0x617F2E2fD72FD9D5503197092aC168c91465E7f2
