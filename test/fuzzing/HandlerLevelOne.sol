// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.26;

import "@perimetersec/fuzzlib/src/IHevm.sol";
import {LevelOne} from "../../src/LevelOne.sol";
import {PostCondition} from "./PostCondition.sol";

contract HandlerLevelOne is PostCondition {
  
  function handler_addTeacher() public {
    bytes memory addTeacher1Calldata = abi.encodeWithSelector(LevelOne.addTeacher.selector, TEACHER_1);
    bytes memory addTeacher2Calldata = abi.encodeWithSelector(LevelOne.addTeacher.selector, TEACHER_2);

    vm.prank(PRINCIPAL);  // TODO: make selectRandomActor() to test error cases
    (bool success1, bytes memory returnData1) = address(levelOneProxy).call{gas: 1000000}(addTeacher1Calldata);

    vm.prank(PRINCIPAL);
    (bool success2, bytes memory returnData2) = address(levelOneProxy).call{gas: 1000000}(addTeacher2Calldata);

    addTeacherPostCondition(success1, returnData1, success2, returnData2);
  }

  /**
   * Chooses a random actor and enrolls them into the school.
   */
  function handler_enroll() public {
    address actor = getRandomAddress(listOfAllActors);
    bytes memory enrollCalldata = abi.encodeWithSelector(LevelOne.enroll.selector, actor);

    vm.prank(actor);
    usdc.approve(address(levelOneProxy), SCHOOL_FEES);  // TODO: this could be randomised to test error cases

    _before();

    vm.prank(actor);
    (bool success, bytes memory returnData) = address(levelOneProxy).call{gas: 1000000}(enrollCalldata);

    _after();

    enrollPostCondition(success, returnData);
  }

  function handler_startSession() public {
    // address actor = getRandomAddress(listOfAllActors);
    bytes memory startSessionCalldata = abi.encodeWithSelector(LevelOne.startSession.selector, 100);  // TODO: 100 could be randomised to test error cases

    vm.prank(PRINCIPAL);
    (bool success, bytes memory returnData) = address(levelOneProxy).call{gas: 1000000}(startSessionCalldata);

    startSessionPostCondition(success, returnData);
  }

  function handler_giveReview() public {
    // address actor = getRandomAddress(listOfAllActors);
    bool review = getRandomReview();
    bytes memory giveReviewCalldata = abi.encodeWithSelector(LevelOne.giveReview.selector, STUDENT_1, review);

    _before();

    vm.prank(TEACHER_1);
    (bool success, bytes memory returnData) = address(levelOneProxy).call{gas: 1000000}(giveReviewCalldata);

    _after();

    giveReviewPostCondition(success, returnData);
  } 

  // TODO: not worth. Run longer Echidna tests.
  // function handler_standardProcess() public {
  //   handler_addTeacher();
  //   handler_enroll();
  //   handler_startSession();
  //   handler_giveReview();
  // }
} 