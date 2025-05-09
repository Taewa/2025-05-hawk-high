// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.26;

abstract contract FuzzConstants {
  
  ///////////////////////////////////////////////////////////////////////////////////////////////
  //                                         Actors                                       
  ///////////////////////////////////////////////////////////////////////////////////////////////

  address internal PRINCIPAL = address(0x10001);
  
  address internal TEACHER_1 = address(0x20001);
  address internal TEACHER_2 = address(0x30001);
  
  address internal STUDENT_1 = address(0x40001);
  address internal STUDENT_2 = address(0x50001);
  address internal STUDENT_3 = address(0x60001);

  // TODO: give roles dynamically instead of setting like above
  address internal actor1 = address(0x70001);
  address internal actor2 = address(0x80001);
  address internal actor3 = address(0x90001);

  address[] internal listOfAllActors = [PRINCIPAL, TEACHER_1, TEACHER_2, STUDENT_1, STUDENT_2, STUDENT_3];

  ///////////////////////////////////////////////////////////////////////////////////////////////
  //                                         Constants                                      
  ///////////////////////////////////////////////////////////////////////////////////////////////
  uint256 internal constant SCHOOL_FEES = 5_000e18; // 5k USDC
} 