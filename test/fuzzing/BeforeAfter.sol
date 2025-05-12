// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "./FuzzSetup.sol";

abstract contract BeforeAfter is FuzzSetup {
  ///////////////////////////////////////////////////////////////////////////////////////////////
  //                                         STRUCTS                                           //
  ///////////////////////////////////////////////////////////////////////////////////////////////
  struct State {
    uint256 usdcBalance;
    address[] listOfStudents;
    address[] listOfTeachers;
    uint256 schoolFees;
    uint256 bursary;
    address principal;
    bool inSession;
  }

  ///////////////////////////////////////////////////////////////////////////////////////////////
  //                                         VARIABLES                                         //
  ///////////////////////////////////////////////////////////////////////////////////////////////

  // callNum => State (callNum: 0 => before, callNum: 1 => after)
  mapping(uint8 => State) states;

  ///////////////////////////////////////////////////////////////////////////////////////////////
  //                                         FUNCTIONS                                         //
  ///////////////////////////////////////////////////////////////////////////////////////////////
  function _before() internal {
    _captureState(0);
  }

  function _after() internal {
    _captureState(1);
  }

  /**
   * @param callNum 0=before, 1=after
   */
  function _captureState(uint8 callNum) internal {
    LevelOne levelOne = LevelOne(address(levelOneProxy));

    // USDC balance of LevelOneProxy
    states[callNum].usdcBalance = usdc.balanceOf(address(levelOneProxy));
    // List of students
    states[callNum].listOfStudents = levelOne.getListOfStudents();
    // List of teachers
    states[callNum].listOfTeachers = levelOne.getListOfTeachers();
    // School fees
    states[callNum].schoolFees = levelOne.getSchoolFeesCost();
    // Bursary amount
    states[callNum].bursary = levelOne.bursary();
    // Principal's address
    states[callNum].principal = levelOne.getPrincipal();
    // In session
    states[callNum].inSession = levelOne.getSessionStatus();
  }
}