// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IGamingEcosystemNFT {
  function mintNFT(address to) external;

  function burnNFT(uint256 tokenId) external;

  function transferNFT(uint256 tokenId, address from, address to) external;

  function ownerOf(uint256 tokenId) external view returns (address);
}

contract BlockchainGamingEcosystem {
  address private immutable OWNER;
  IGamingEcosystemNFT private immutable nft;
  uint256 private tokenCounter;

  mapping(address => bool) private registered;
  mapping(uint256 => bool) private gameIDExists;
  mapping(uint256 => bool) private gameIsActive;
  mapping(string => bool) private gameNameExists;
  mapping(string => bool) private usernameExists;
  mapping(uint256 => bool) private tokenActive;

  mapping(uint256 => address) private ownership;
  mapping(uint256 => uint256) private tokenIdToGameID;
  mapping(uint256 => string) private gameIDToName;

  mapping(address => uint256) private credits;
  mapping(address => string) private username;
  mapping(address => uint256) private totalPlayerAssets;

  mapping(uint256 => uint256) private tokenPrice;
  mapping(uint256 => uint256[]) private tokensInGame; //gameID => tokens
  mapping(uint256 => uint256) private lastBuyingPrice; //gameID => price

  constructor(address _nftAddress) {
    OWNER = msg.sender;
    nft = IGamingEcosystemNFT(_nftAddress);
  }

  function ownerOf(uint256 tokenID) public view returns (address) {
    return ownership[tokenID];
  }

  function registerPlayer(string memory userName) external {
    unchecked {
      if (msg.sender == OWNER || registered[msg.sender] || bytes(userName).length < 3 || usernameExists[userName])
        revert();
      usernameExists[userName] = true;
      username[msg.sender] = userName;
      registered[msg.sender] = true;
      credits[msg.sender] = 1000;
    }
  }

  function createGame(string memory gameName, uint256 gameID) external {
    unchecked {
      if (msg.sender != OWNER || gameIDExists[gameID] || gameNameExists[gameName]) revert();
      if (gameNameExists[gameName]) revert();
      gameIDToName[gameID] = gameName;
      gameIsActive[gameID] = true;
      gameIDExists[gameID] = true;
      gameNameExists[gameName] = true;
    }
  }

  function removeGame(uint256 gameID) external {
    unchecked {
      if (msg.sender != OWNER || !gameIsActive[gameID]) revert();
      gameIsActive[gameID] = false;

      uint256[] memory tokens = tokensInGame[gameID];
      address playerToBeRefunded;
      for (uint256 i; i < tokens.length; ++i) {
        if (ownerOf(tokens[i]) != address(0)) {
          playerToBeRefunded = ownerOf(tokens[i]);
          nft.burnNFT(tokens[i]);
          ownership[tokens[i]] = address(0);
          credits[playerToBeRefunded] += tokenPrice[tokens[i]];
          --totalPlayerAssets[playerToBeRefunded];
          tokenActive[tokens[i]] = false;
        }
      }
      delete tokensInGame[gameID];
    }
  }

  function buyAsset(uint256 gameID) external {
    unchecked {
      if (!gameIsActive[gameID]) revert();

      uint256 buyingPrice = calculatePrice(gameID);
      if (buyingPrice > credits[msg.sender]) revert();
      lastBuyingPrice[gameID] = buyingPrice;
      credits[msg.sender] -= buyingPrice;

      ownership[tokenCounter] = msg.sender;
      tokensInGame[gameID].push(tokenCounter);
      tokenIdToGameID[tokenCounter] = gameID;
      tokenPrice[tokenCounter] = buyingPrice;
      tokenActive[tokenCounter] = true;

      ++totalPlayerAssets[msg.sender];
      ++tokenCounter;

      nft.mintNFT(msg.sender);
    }
  }

  function sellAsset(uint256 _tokenID) external {
    unchecked {
      // if (_tokenID > tokenCounter) revert();
      if (ownerOf(_tokenID) != msg.sender) revert();
      nft.burnNFT(_tokenID);

      ownership[tokenCounter] = address(0);
      --totalPlayerAssets[msg.sender];
      tokenActive[_tokenID] = false;
      uint256 gameID = tokenIdToGameID[_tokenID];
      _deleteTokenFromGame(_tokenID, gameID);
      uint256 currentPriceInGame = calculatePrice(gameID);
      credits[msg.sender] += currentPriceInGame;
    }
  }

  function _deleteTokenFromGame(uint256 tokenID, uint256 gameID) private {
    unchecked {
      uint256[] storage gameTokens = tokensInGame[gameID];
      for (uint256 i; i < gameTokens.length; ++i) {
        if (gameTokens[i] == tokenID) {
          gameTokens[i] = gameTokens[gameTokens.length - 1];
          gameTokens.pop();
          break;
        }
      }
    }
  }

  function transferAsset(uint256 _tokenID, address to) external {
    unchecked {
      // if (_tokenID > tokenCounter) revert();
      if (!registered[msg.sender] || ownerOf(_tokenID) != msg.sender) revert();
      if (!registered[to] || msg.sender == to) revert();

      ownership[_tokenID] = to;
      ++totalPlayerAssets[to];
      --totalPlayerAssets[msg.sender];

      nft.transferNFT(_tokenID, msg.sender, to);
    }
  }

  function calculatePrice(uint256 gameID) private view returns (uint256) {
    uint256 lastPrice = lastBuyingPrice[gameID];
    if (lastPrice == 0) return 250;
    else return (lastPrice + ((lastPrice * 10) / 100));
  }

  function viewProfile(
    address playerAddress
  ) external view returns (string memory userName, uint256 balance, uint256 numberOfNFTs) {
    if (playerAddress == OWNER || !registered[playerAddress]) revert();
    if (msg.sender != OWNER && !registered[msg.sender]) revert();
    return (username[playerAddress], credits[playerAddress], totalPlayerAssets[playerAddress]);
  }

  function viewAsset(uint256 tokenID) external view returns (address owner, string memory gameName, uint256 price) {
    if (msg.sender != OWNER && !registered[msg.sender]) revert();
    if (tokenID > tokenCounter) revert();
    owner = ownerOf(tokenID);
    if (owner != address(0)) {
      return (owner, gameIDToName[tokenIdToGameID[tokenID]], tokenPrice[tokenID]);
    } else revert();
  }
}
