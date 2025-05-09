// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

abstract contract PropertiesDescriptions {
  string internal constant BAL_01 = "BAL-01: during the session, the USDC balance of contract must not be changed"; // even if students are expelled
  string internal constant BAL_02 = "BAL-02: after the session, the balance of principal and teachers must increase"; // principal and teachers get paid
  // TODO: Consider LevelTwo.sol. The USDC balance.
  string internal constant BAL_03 = "BAL-03: the USDC balance of the contract must be equal to the USDC amount of students enrolled";
  string internal constant BAL_04 = "BAL-04: when a session is active,the USDC balance of the contract must be equal to bursary amount";
  string internal constant BAL_05 = "BAL-05: There must be USDC when a session is started";
  
  
  string internal constant SESS_01 = "SESS-01: There must be student when a session is started";
  string internal constant SESS_02 = "SESS-02: There must be teacher when a session is started";



}
