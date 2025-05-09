// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../../../src/LevelOne.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "../../../mocks/MockUSDC.sol";

// forge test --match-path test/fuzzing/bugs/poc/bug-1.sol -vv
contract Bug1Test is Test {
  LevelOne public levelOne;
  address public student;
  address public teacher;
  address public principal;
  uint256 public schoolFees = 5_000e18;
  MockUSDC public usdc;

  function setUp() public {
    // Deploy contracts
    usdc = new MockUSDC();
    LevelOne implementation = new LevelOne();
    ERC1967Proxy proxy = new ERC1967Proxy(address(implementation), "");
    levelOne = LevelOne(address(proxy));
    
    // Initialize LevelOne
    principal = makeAddr("principal");
    levelOne.initialize(principal, schoolFees, address(usdc));
    
    // Create test accounts
    student = makeAddr("student");
    teacher = makeAddr("teacher");
    
    // Mint USDC to student and approve
    usdc.mint(student, schoolFees);
    vm.prank(student);
    usdc.approve(address(levelOne), schoolFees);
    
    // Enroll student and add teacher
    vm.prank(student);
    levelOne.enroll();
    
    // Add teacher
    vm.prank(principal);
    levelOne.addTeacher(teacher);

    // Start a session
    vm.prank(principal);
    levelOne.startSession(80);
  }

  function testArithmeticUnderflow() public {
    // Move time forward by 1 week before first review
    vm.warp(block.timestamp + 1 weeks);
    
    // Give 10 bad reviews first (100 - 10*10 = 0)
    for(uint i = 0; i < 10; i++) {
      vm.prank(teacher);
      levelOne.giveReview(student, false);
      // Move time forward by 1 week
      vm.warp(block.timestamp + 1 weeks);
    }
    
    // Get student score after 10 reviews
    uint256 score = levelOne.studentScore(student);
    assertEq(score, 0, "Score should be 0 after 10 bad reviews");
    
    // Try to give one more review which should cause arithmetic underflow
    vm.prank(teacher);
    vm.expectRevert(stdError.arithmeticError);  // abi.encodeWithSignature("Panic(uint256)", 0x11);
    levelOne.giveReview(student, false);
  }
} 