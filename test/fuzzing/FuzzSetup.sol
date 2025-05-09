// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.26;

// import {Test} from "forge-std/Test.sol";  // TODO: try to use makeAddr()
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@perimetersec/fuzzlib/src/IHevm.sol";
import {LevelOne} from "../../src/LevelOne.sol";
import {MockUSDC} from "../mocks/MockUSDC.sol";
import {FuzzStorageVariables} from "./FuzzStorageVariables.sol";

contract FuzzSetup is FuzzStorageVariables {
  function setup() internal {
    setContracts();
    mintStudents();
  }

  function setContracts() internal {
    usdc = new MockUSDC();
    levelOneImplementation = new LevelOne();
    levelOneProxy = new ERC1967Proxy(address(levelOneImplementation), "");
    LevelOne(address(levelOneProxy)).initialize(PRINCIPAL, SCHOOL_FEES, address(usdc));

    // Test SCHOOL_FEES
    assert(SCHOOL_FEES > 0);
    assert(SCHOOL_FEES <= type(uint256).max / 1000); // Prevent overflow with reasonable number of students

    // Test proxy initialization
    LevelOne proxy = LevelOne(address(levelOneProxy));
    assert(proxy.getPrincipal() == PRINCIPAL);
    assert(proxy.getSchoolFeesCost() == SCHOOL_FEES);
    assert(proxy.getSchoolFeesToken() == address(usdc));

    // Test reinitialization prevention: since the proxy is already initialized, it should not be possible to reinitialize it
    try LevelOne(address(levelOneProxy)).initialize(PRINCIPAL, SCHOOL_FEES, address(usdc)) {
      assert(false); // Should not reach here
    } catch {
      assert(true);
    }
  }
  
  function mintStudents() internal {
    usdc.mint(STUDENT_1, SCHOOL_FEES);
    usdc.mint(STUDENT_2, SCHOOL_FEES);
    usdc.mint(STUDENT_3, SCHOOL_FEES);

    // TODO: add appvoe logic here
    assert(usdc.balanceOf(STUDENT_1) == SCHOOL_FEES);
    assert(usdc.balanceOf(STUDENT_2) == SCHOOL_FEES);
    assert(usdc.balanceOf(STUDENT_3) == SCHOOL_FEES);
  }
}   