// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.26;

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "./FuzzConstants.sol";
import {LevelOne} from "../../src/LevelOne.sol";
import {MockUSDC} from "../mocks/MockUSDC.sol";
abstract contract FuzzStorageVariables is FuzzConstants {
  ///////////////////////////////////////////////////////////////////////////////////////////////
  //                                         Contracts                                       
  ///////////////////////////////////////////////////////////////////////////////////////////////
  LevelOne internal levelOneImplementation;
  ERC1967Proxy internal levelOneProxy;
  MockUSDC internal usdc;

  // These will be made as "before/after"
  // // Track student balances
  // mapping(address => uint256) public studentBalances;
  // // Track graduation status
  // mapping(address => bool) public isGraduated;
  // // Track total fees paid
  // uint256 public totalFeesPaid;
  // // Track number of graduates
  // uint256 public numberOfGraduates;
} 