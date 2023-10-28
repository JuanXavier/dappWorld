// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract TicketBooking {
  uint256[] private availableSeats;
  mapping(address => uint256[]) private bookedSeats;
  mapping(uint256 => bool) private seatBooked;

  constructor() {
    unchecked {
      for (uint256 i = 1; i < 21; ++i) availableSeats.push(i);
    }
  }

  function bookSeats(uint256[] memory seatNumbers) external {
    unchecked {
      if (seatNumbers.length == 0 || seatNumbers.length > 4) revert();

      if (bookedSeats[msg.sender].length == 4) revert();
      uint256 seatNumber;

      for (uint256 i; i < seatNumbers.length; ++i) {
        seatNumber = seatNumbers[i];
        if (!isSeatAvailable(seatNumber) || isSeatBooked(seatNumber)) revert();
        bookedSeats[msg.sender].push(seatNumber);
        seatBooked[seatNumber] = true;
        removeSeatFromAvailableSeats(seatNumber);
      }
    }
  }

  function showAvailableSeats() external view returns (uint256[] memory) {
    return availableSeats;
  }

  function checkAvailability(uint256 seatNumber) external view returns (bool) {
    return isSeatAvailable(seatNumber);
  }

  function myTickets() external view returns (uint256[] memory) {
    return bookedSeats[msg.sender];
  }

  function isSeatAvailable(uint256 seatNumber) private view returns (bool) {
    unchecked {
      if (seatNumber == 0 || seatNumber > 20) return false;
      for (uint256 i; i < availableSeats.length; ++i) {
        if (availableSeats[i] == seatNumber) return true;
      }
      return false;
    }
  }

  function isSeatBooked(uint256 seatNumber) private view returns (bool) {
    return seatBooked[seatNumber];
  }

  function removeSeatFromAvailableSeats(uint256 seatNumber) private {
    unchecked {
      for (uint256 i; i < availableSeats.length; ++i) {
        if (availableSeats[i] == seatNumber) {
          availableSeats[i] = availableSeats[availableSeats.length - 1];
          availableSeats.pop();
          break;
        }
      }
    }
  }
}
