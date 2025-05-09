// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "./PropertiesBase.sol";

abstract contract Properties_BAL is PropertiesBase {

  // BAL-01: during the session, the USDC balance of contract must not be changed
  function invariant_BAL_01() internal {
   // TODO: implement
  }

  // BAL-03: the USDC balance of the contract must be equal to the USDC amount of students enrolled
  // TODO: schoolFees, contractBalance should come from beforeAfter because ...(trust issues)
  function invariant_BAL_03(uint256 contractBalance, address[] memory studentsEnrolled, uint256 schoolFees) internal {
    uint256 studentsEnrolledBalance = 0;

    for (uint256 i = 0; i < studentsEnrolled.length; i++) {
      studentsEnrolledBalance += schoolFees;
    }

    fl.eq(contractBalance, studentsEnrolledBalance, BAL_03);
  }

  // BAL-04: the USDC balance of the contract must be equal to bursary amount
  function invariant_BAL_04(uint256 contractBalance, uint256 bursaryAmount) internal {
    fl.eq(contractBalance, bursaryAmount, BAL_04);
  }

  // BAL-05: There must be USDC when a session is started
  function invariant_BAL_05(uint256 contractBalance) internal {
    fl.gte(contractBalance, SCHOOL_FEES, BAL_05);
  }
}