// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Properties} from "./Properties/Properties.sol";
import {LevelOne} from "../../src/LevelOne.sol";
import {IERC20Errors} from "openzeppelin-contracts/contracts/interfaces/draft-IERC6093.sol";

contract PostCondition is Properties {

  function addTeacherPostCondition(bool success1, bytes memory returnData1, bool success2, bytes memory returnData2) internal {
    address[] memory listOfTeachers = getLevelOneProxy().getListOfTeachers();

    if (success1 && success2) {
      fl.eq(listOfTeachers.length, 2, "List of teachers should have 2 teachers");
      fl.eq(listOfTeachers[0], TEACHER_1, "Teacher 1 should be in the list");
      fl.eq(listOfTeachers[1], TEACHER_2, "Teacher 2 should be in the list");
    } else {
      bytes4[] memory allowedErrors = new bytes4[](2);
      allowedErrors[0] = LevelOne.HH__TeacherExists.selector;
      allowedErrors[1] = LevelOne.HH__AlreadyInSession.selector;

      fl.errAllow(bytes4(returnData1), allowedErrors, "addTeacher() error");
    }
  }

  function enrollPostCondition(bool success, bytes memory returnData) internal {
    if (success) {
      invariant_BAL_03(
        usdc.balanceOf(address(levelOneProxy)), 
        getLevelOneProxy().getListOfStudents(), 
        getLevelOneProxy().getSchoolFeesCost()
      );

      invariant_BAL_04(
        usdc.balanceOf(address(levelOneProxy)), 
        getLevelOneProxy().bursary()
      );
    } else {
      bytes4[] memory allowedErrors = new bytes4[](4);
      allowedErrors[0] = LevelOne.HH__NotAllowed.selector;
      allowedErrors[1] = LevelOne.HH__StudentExists.selector;
      allowedErrors[2] = IERC20Errors.ERC20InsufficientBalance.selector;
      allowedErrors[3] = LevelOne.HH__AlreadyInSession.selector;

      fl.errAllow(bytes4(returnData), allowedErrors, "enroll() error");
    }
  }

  function startSessionPostCondition(bool success, bytes memory returnData) internal {
    if (success) {
      // TODO: I think it's worth to check but worth to make an invariant?
      fl.eq(getLevelOneProxy().getSessionStatus(), true, "Session should be active");

      // invariant_SESS_01(getLevelOneProxy().getListOfStudents()); // TODO: this bug blocks the progress of the fuzzing
      // invariant_SESS_02(getLevelOneProxy().getListOfTeachers()); // TODO: this bug blocks the progress of the fuzzing
      // invariant_BAL_05(usdc.balanceOf(address(levelOneProxy)));  // TODO: this bug blocks the progress of the fuzzing
    } else {
      bytes4[] memory allowedErrors = new bytes4[](2);
      allowedErrors[0] = LevelOne.HH__AlreadyInSession.selector;
      allowedErrors[1] = LevelOne.HH__NotPrincipal.selector;

      fl.errAllow(bytes4(returnData), allowedErrors, "startSession() error");
    }
  }

  function giveReviewPostCondition(bool success, bytes memory returnData) internal {
    if (success) {
      invariant_BAL_03(
        usdc.balanceOf(address(levelOneProxy)), 
        getLevelOneProxy().getListOfStudents(), 
        getLevelOneProxy().getSchoolFeesCost()
      );

      invariant_BAL_04(
        usdc.balanceOf(address(levelOneProxy)), 
        getLevelOneProxy().bursary()
      );
    } else {
      bytes[] memory allowedRequireErrors = new bytes[](1);
      allowedRequireErrors[0] = abi.encode("Reviews can only be given once per week");

      bytes4[] memory allowedErrors = new bytes4[](2);
      allowedErrors[0] = LevelOne.HH__NotTeacher.selector;
      allowedErrors[1] = LevelOne.HH__StudentDoesNotExist.selector;

      allowErrors(returnData, allowedRequireErrors, allowedErrors, "giveReview() error", true);
    }
  }
}
