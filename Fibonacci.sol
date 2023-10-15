// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Fibonacci {
  function fibonacci(uint256 n) external pure returns (uint256) {
    if (n == 0) return 0;
    else if (n == 1) return 1;
    else {
      uint256 a = 0;
      uint256 b = 1;

      for (uint256 i = 2; i <= n; ++i) {
        uint256 temp = a + b;
        a = b;
        b = temp;
      }
      return b;
    }
  }
}

// 2
// 1
