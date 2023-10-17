// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//To find the value of n+1 th Fibonacci number
contract Fibonacci {
  /*
  eg, with input n = 6
  N = 6, temp = 1, a = 0, b = 1
  N = 5, temp = 0, a = 1, b = 1
  N = 4, temp = 1, a = 1, b = 2
  N = 3, temp = 1, a = 2, b = 3
  N = 2, temp = 2, a = 3, b = 5
  N = 1, temp = 3, a = 5, b = 8
  */
  function fibonacci(uint256 n) external pure returns (uint256 b) {
    // prettier-ignore
    assembly {
        for {let a := 1} gt(n, 0) {n := sub(n, 1)} {
          let c := a
          a := b
          b := add(b, c)
        }
      }
  }
}
