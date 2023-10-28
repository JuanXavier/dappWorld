// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PalindromeChecker {
  function isPalindrome(string calldata input) external pure returns (bool) {
    unchecked {
      bytes calldata str = bytes(input);
      if (str.length == 0) return true;
      uint256 len = str.length;
      uint256 i;
      uint256 j = len - 1;

      while (i < j) {
        while (i < len && !_isAlphanumeric(str[i])) ++i;
        while (j >= 0 && !_isAlphanumeric(str[j])) --j;
        if (i >= j) break;
        if (_toLower(str[i]) != _toLower(str[j])) return false;
        ++i;
        --j;
      }

      return true;
    }
  }

  function _isAlphanumeric(bytes1 b) private pure returns (bool) {
    unchecked {
      return
        (b >= bytes1("a") && b <= bytes1("z")) ||
        (b >= bytes1("A") && b <= bytes1("Z")) ||
        (b >= bytes1("0") && b <= bytes1("9"));
    }
  }

  function _toLower(bytes1 b) private pure returns (bytes1) {
    unchecked {
      if (b >= bytes1("A") && b <= bytes1("Z")) return bytes1(uint8(b) + 32);
      return b;
    }
  }
}
