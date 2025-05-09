// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "./FuzzSetup.sol";

abstract contract BeforeAfter is FuzzSetup {
  ///////////////////////////////////////////////////////////////////////////////////////////////
  //                                         STRUCTS                                           //
  ///////////////////////////////////////////////////////////////////////////////////////////////


  ///////////////////////////////////////////////////////////////////////////////////////////////
  //                                         VARIABLES                                         //
  ///////////////////////////////////////////////////////////////////////////////////////////////

  // callNum => State (callNum: 0 => before, callNum: 1 => after)
  // mapping(uint8 => RPSState) states;

  ///////////////////////////////////////////////////////////////////////////////////////////////
  //                                         FUNCTIONS                                         //
  ///////////////////////////////////////////////////////////////////////////////////////////////

  // function _before(address actor, uint256 etherBalance) internal {
  function _before(address actor) internal {
    _captureState(0, actor);
  }

  function _after(address actor) internal {
    _captureState(1, actor);
  }

  /**
   * @param callNum 0=before, 1=after
   */
  function _captureState(uint8 callNum, address actor) internal {
    
  }
}