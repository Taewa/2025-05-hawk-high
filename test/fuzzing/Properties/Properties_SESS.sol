// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "./PropertiesBase.sol";

abstract contract Properties_SESS is PropertiesBase {

  // SESS-01: There must be student when a session is started
  function invariant_SESS_01(address[] memory studentsEnrolled) internal {
    fl.gt(studentsEnrolled.length, 0, SESS_01);
  }

  // SESS-02: There must be teacher when a session is started
  function invariant_SESS_02(address[] memory teachers) internal {
    fl.gt(teachers.length, 0, SESS_02);
  }
}