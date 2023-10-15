// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

enum GameStatus {
  Inactive,
  Active
}

contract ParchiThap {
  GameStatus public gameStatus;
  address private immutable OWNER;
  uint96 public startTime;
  uint256 internal randomCounter;

  address[4] public players;
  uint8[4][4] public gameState;

  uint8 playerInTurnIndex;
  mapping(address => bool) public isPlayer;
  mapping(address => uint256) private wins;

  /* ****************************************************** */
  /*                      INITIALIZERS                      */
  /* ****************************************************** */
  function _onlyOwner() private view {
    if (msg.sender != OWNER) revert();
  }

  function _onlyInStatus(GameStatus _gameStatus) private view {
    if (gameStatus != _gameStatus) revert();
  }

  constructor() {
    OWNER = msg.sender;
    randomCounter = block.timestamp;
  }

  /* ****************************************************** */
  /*                         PRIVATE                        */
  /* ****************************************************** */

  // Should generatean array of 4 arrays the do not add 4 in each array and the all the indices are equal to 4 as well
  function _newGameState() public view returns (uint8[4][4] memory) {
    uint8 horizontalAmountLeft = 4; // horizontal amount
    uint8[4] memory verticalAmountsLeft = [4, 4, 4, 4]; // vertical sum

    // bool[4] memory columnFull = [false, false, false, false];

    uint8[4] memory randoms = [0, 0, 0, 0];
    uint8[4][4] memory newGameState;
    uint8 randomNumber;

    for (uint256 j; j < 4; ++j) {
      for (uint256 i; i < 4; ++i) {
        // On last iteration just fill the array with the remaining available
        if (j == 3) {
          randoms = verticalAmountsLeft;
          newGameState[j] = randoms;
          break;
        }

        randomNumber = uint8(uint256(keccak256(abi.encode(i, j, gasleft(), block.timestamp))) % 5);

        if (j < 2) {
          // If next column is full, then fill the array with the remaining available
          if (i != 3 && verticalAmountsLeft[i + 1] == 0) randoms[i] = horizontalAmountLeft;

          if (randomNumber <= horizontalAmountLeft) {
            if (randomNumber <= verticalAmountsLeft[i]) {
              randoms[i] = randomNumber;
              horizontalAmountLeft -= randomNumber;
              verticalAmountsLeft[i] -= randomNumber;
            } else {
              randoms[i] = verticalAmountsLeft[i];
              horizontalAmountLeft -= verticalAmountsLeft[i];
              verticalAmountsLeft[i] = 0;
            }

            if (i == 3) {
              randoms[i] = horizontalAmountLeft;
              horizontalAmountLeft = 0;
            }
          } else {
            randoms[i] = horizontalAmountLeft;
            verticalAmountsLeft[i] -= horizontalAmountLeft;
            horizontalAmountLeft = 0;
          }
        }

        if (j == 2) {
          if (horizontalAmountLeft > 0) {
            if (verticalAmountsLeft[i] >= horizontalAmountLeft) {
              randoms[i] = horizontalAmountLeft;
              verticalAmountsLeft[i] -= horizontalAmountLeft;
              horizontalAmountLeft = 0;
            }
          }
        }
      }

      // Update the new state
      newGameState[j] = randoms;

      // Reset
      randoms = [0, 0, 0, 0];
      horizontalAmountLeft = 4;
    }

    return newGameState;
  }

  function _addPlayers(address[4] memory _players) private {
    unchecked {
      uint256 i = 4;
      while (i > 0) {
        if (players[i] != address(0) && players[i] != msg.sender && !isPlayer[_players[i]]) {
          isPlayer[_players[i]] = true;
          players[i] = _players[i];
        } else revert();
        --i;
      }
    }
  }

  function _setState(uint8[4][4] calldata _state) private pure {
    unchecked {
      uint256 total;
      uint256 i;

      // Check for each vertical adding up to 4
      for (; i < 4; ++i) {
        total = _state[0][i] + _state[1][i] + _state[2][i] + _state[3][i];
        if (total != 4) revert();
      }

      delete i;

      // Check for horizontal adding up to 4
      for (; i < 4; ++i) {
        if (_addValuesInArray(_state[i]) != 4) revert();
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
      return index;
    }
  }

  function _addValuesInArray(uint8[4] memory array) internal pure returns (uint256) {
    return array[0] + array[1] + array[2] + array[3];
  }

  /* ****************************************************** */
  /*                        EXTERNAL                        */
  /* ****************************************************** */

  function startGame(address p1, address p2, address p3, address p4) external {
    _onlyOwner();
    _onlyInStatus(GameStatus.Inactive);

    address[4] memory _players = [p1, p2, p3, p4];
    _addPlayers(_players);

    gameStatus = GameStatus.Active;
    players = _players;
    startTime = uint96(block.timestamp);

    // todo distribute parchis generating 16 randdom numbers between 0 and 4
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

      uint8 nextPlayerInTurnIndex = (_playerInTurnIndex + 1) % 4;

      if (playerParchis[_type] > 0) {
        --gameState[_playerInTurnIndex][_type];
        ++gameState[nextPlayerInTurnIndex][_type];
      } else revert();

      playerInTurnIndex = nextPlayerInTurnIndex;
    }
  }

  function endGame() public {
    if (!isPlayer[msg.sender]) revert();
    if (block.timestamp < startTime + 1 hours) revert();
    _resetGame();
  }

  function claimWin() external {
    if (!isPlayer[msg.sender]) revert();
    uint256 playerIndex = _getIndex();

    for (uint256 i; i < 4; ++i) {
      if (gameState[playerIndex][i] == 4) {
        _resetGame();
        ++wins[msg.sender];
        return;
      }
    }

    revert();
  }

  function _resetGame() internal {
    delete playerInTurnIndex;
    delete players;
    delete gameState;
    gameStatus = GameStatus.Inactive;
  }

  function getState() external view returns (address[4] memory, address turn, uint8[4][4] memory) {
    if (msg.sender != OWNER) revert();
    if (gameStatus == GameStatus.Inactive) revert();
    return (players, players[playerInTurnIndex], gameState);
  }

  function getWins(address player) external view returns (uint256) {
    return wins[player];
  }

  function myParchis() external view returns (uint8[4] memory) {
    unchecked {
      if (!isPlayer[msg.sender]) revert();
      if (gameStatus == GameStatus.Inactive) revert();

      uint256 index = _getIndex();
      return gameState[index];
    }
  }
}
