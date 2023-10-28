// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract RightTriangle {
  function check(uint256 a, uint256 b, uint256 c) external pure returns (bool) {
    unchecked {
      if (a ** 2 + b ** 2 == c ** 2 || a ** 2 + c ** 2 == b ** 2 || b ** 2 + c ** 2 == a ** 2) return true;
    }
  }
}
