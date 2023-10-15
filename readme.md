"16 Parchi Thap" is an enjoyable card game where four friends aim to collect four chits, called parchis, of the same type without revealing their hand to one another. They take turns passing chits, and the first to gather four of a kind wins the game!

Rules of 16 Parchi Thap:

There are total 16 parchis(chits), with each parchi being categorized as type 1, 2, 3, or 4. Four parchis of each type are available.
Before the game commences, the four participating players start with no parchis.
In the following examples, the convention for representing chits is as follows:
Parchis held by a player are represented by an array of length 4, where the nth element in the array indicates the number of parchis of type n.
For example, the representation [1,2,0,1] means that the player has
1 parchi of type 1,
2 parchis of type 2,
0 parchis of type 3, and
1 parchi of type 4.
Representation of all the distributed parchis in the game will be an array of representation of array of ‘arrays of parchis of players
For example, the representation [1,2,0,1] means that the player has
the array [0,1,1,1] corresponds to the parchis held by 1st player (who started the game),
the array [3,0,1,1] corresponds to the parchis held by 2nd player,
the array [0,2,1,1] corresponds to the parchis held by 3rd player, and
the array [1,1,1,1] corresponds to the parchis held by 4th player.
The game then begins with random distribution of 4 parchis to each participant.
Example - [[0,2,1,1],[1,0,2,1],[3,0,0,1],[0,2,1,1]]
Players do not reveal the types of their parchis to others. To win the game, a player must collect 4 parchis of any single type.
The game runs in cyclic manner, with the first player passing one chit to the next player. For example, consider the state of the game after the initial distribution: [[0,2,1,1],[1,0,2,1],[3,0,0,1],[0,2,1,1]]. In this state, player 1 passes a parchi of type 3 to player 2.
The next player then sees the type of parchi he/she has and then keeping in mind that he wants to gather 4 parchis of any one type, strategically passes one of the parchis he/she has to the next player.
Example - now the state of game is [[0,2,0,1],[1,0,3,1],[3,0,0,1],[0,2,1,1]] and its turn of player 2 who passes parchi of type 1 to player 3. The new state of the game will be [[0,2,0,1],[0,0,3,1],[4,0,0,1],[0,2,1,1]]
As soon as a player gathers 4 parchis of a type, the player can claim the win buy showing his/her parchis to the other players.
Example - Player 3 can claim win now since the player has 4 parchis of type 1.
In the event that multiple players collect 4 parchis of a single type, the player who first claims victory is declared the winner.
Please note that at any point during the game, a player can not have more than 5 parchis and less than 3 parchis.

Implement a smart contract of the above game with the following public function such that :

The deployer of the smart contract (let’s call him/her owner) can start the game whose purpose is to manage the game.
Any player can end the game either by claiming a valid win, or , by directly choosing to end the game given that at least 1 hour has passed since the start of the game.
Players can see how many time any player corresponding to some address has won the game.
After the end of the game, new game can be started again by the owner.

Input:
startGame(address player1, address player2, address player3, address player4) : Using this function, owner can pass the address of 4 valid players in the arguments in order of their turns. The parchis should get distributed randomly among the players, such that each player recieves 4 parchis. This function is only accessible to owner. The owner cannot be a player. The addresses should be valid corresponding to 4 different valid players.

setState(address[4] \_players, uint8[4][4] \_state) : Using this function, owner can start a game by assigning parchis to the players, given that there is currently no game in progress.

\_players is the array of addresses of the players. All the addesses must be valid addresses and owner can not be a player. The order of the turns of players is same as the order of the players in the \_players array in a cyclic manner starting with the first address having first turn.
\_state is an array of ‘arrays of uint8’ (ranging from 0 to 4 inclusive). This represents a state of the game at any particular point. The state should be valid state, which is attainable in a real game through the above rules mentioned. The representation of state is same as the 3rd point in game rules mentioned above. For an invalid state, the transaction must revert.
Example -
[[0,1,1,1],[0,2,2,1],[1,1,1,1],[3,0,0,1]] - is a valid state, where 4th player has the current turn
[[1,1,1,1],[2,0,1,1],[0,2,1,1],[1,1,1,1]] - is a valid state, where 1st player has the current turn.
[[1,1,1,2],[2,0,1,1],[0,2,1,1],[1,1,1,0]] - is an invalid state, since player 1 always has the 1st chance. But the given state is attainable only when 4th player has 1st turn of the game.
passParchi(uint8 \_type) : This function is only accessible to a valid player during the game in his/her own turn. The player must have at least one parchi of type ‘\_type’.

endGame() : Any player can access this during the game after at least 1 hour has passed since the start of the game. This will end the game abruptly without concluding any winner. This is to prevent cases where player either delay their turn, or try to keep 1 parchi of all 4 types with them to prevent anyone from winning the game.

claimWin() : Any player can access this during the game given that the player has 4 parchis of same type. This will end the game and record a win corresponding to the player who has called this function.

Output:
getState() returns (address[4] players, address turn, uint8[4][4] game): This function can only be accessed by the owner when a game is in progress. players corresponds to the array of addresses of players in the game in order of their turns. turn corresponds to the address of the player who has the ongoing turn. game corresponds to the current state of the parchis in the game as mentioned above.

getWins(address player) returns (uint):This function can be accessed by anyone by providing an address of a valid player to get the number of wins corresponding to that address.

myParchis returns (uint8[4] parchis):This function can be accessed by any player in an ongoing game to view his/her parchis. The format of the returned array is same as mentioned earlier.

Example 1

Input/Output
Function
Sender address
Parameter
Expected output
Input
setState()
Owner
([<Address 1>,<Address 2>,<Address 3>,<Address 4>] , [[1,1,1,1],[1,1,1,1],[1,1,1,1],[1,1,1,1]])
Output
getState()
Owner
()
( [<Address 1>,<Address 2>,<Address 3>,<Address 4>] , <Address 1>,[1,1,1,1],[1,1,1,1],[1,1,1,1],[1,1,1,1])
Input
passParchi()
Address 1
(1)
Output
getState()
Owner
()
( [<Address 1>,<Address 2>,<Address 3>,<Address 4>] , <Address 2>,[0,1,1,1],[2,1,1,1],[1,1,1,1],[1,1,1,1])
