// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {HandlerLevelOne} from "./HandlerLevelOne.sol";

contract Fuzz is HandlerLevelOne {
  constructor() payable {
    setup();
  }
}