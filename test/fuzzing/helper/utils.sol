// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.26;

import {LevelOne} from "../../../src/LevelOne.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {FuzzStorageVariables} from "../FuzzStorageVariables.sol";
import '@perimetersec/fuzzlib/src/FuzzBase.sol';

abstract contract Utils is FuzzStorageVariables, FuzzBase {
  // Returns a random address from the list of addresses
  function getRandomAddress(address[] memory listOfAddresses) internal view returns (address) {
    return listOfAddresses[uint256(keccak256(abi.encodePacked(block.timestamp))) % listOfAddresses.length];
  }

  // Returns the LevelOne contract instance
  function getLevelOneProxy() internal view returns (LevelOne) {
    return LevelOne(address(levelOneProxy));
  }

  // Returns a random boolean value
  function getRandomReview() internal view returns (bool) {
    return uint256(keccak256(abi.encodePacked(block.timestamp))) % 2 == 0;
  }

  function allowErrors(  
    bytes memory errorData,
    bytes[] memory allowedRequireErrorMessages
  ) internal {
    allowErrors(errorData, allowedRequireErrorMessages, new bytes4[](0), "", false);
  }

  function allowErrors(  
    bytes memory errorData,
    bytes4[] memory allowedCustomErrors,
    string memory errorContext
  ) internal {
    allowErrors(errorData, new bytes[](0), allowedCustomErrors, errorContext, false);
  }

  function allowErrors(  
    bytes memory errorData,
    bytes[] memory allowedRequireErrorMessages,
    bytes4[] memory allowedCustomErrors,
    string memory errorContext
  ) internal {
    allowErrors(errorData, allowedRequireErrorMessages, allowedCustomErrors, errorContext, false);
  }

  function allowErrors(  
    bytes memory errorData,
    bytes4[] memory allowedCustomErrors,
    string memory errorContext,
    bool allowEmptyRequireError
  ) internal {
    allowErrors(errorData, new bytes[](0), allowedCustomErrors, errorContext, allowEmptyRequireError);
  }

  /**
   * Allow require failure & custom errors
   * @param errorData: return data from a function call. In this case, it's a failure data
   * @param allowedRequireErrorMessages: allowed require failure messages. It's a string array
   * @param allowedCustomErrors: allowed custom errors. It can be just 4 bytes function selector or it could be longer
   * @param errorContext: error context: A message to describe the error
   * @param allowEmptyRequireError: allow require failure without message
   */
  function allowErrors(  
    bytes memory errorData,
    bytes[] memory allowedRequireErrorMessages,
    bytes4[] memory allowedCustomErrors,
    string memory errorContext,
    bool allowEmptyRequireError
  ) internal {
    if (errorData.length == 0) {  // ex: require(false); <= when there is no error message, errorData is empty
      // 1. empty error case (ex: require(false))
      handleEmptyError(allowEmptyRequireError);
      return;
    }

    if (errorData.length < 4) {
      fl.t(false, "unexpected error data length");
      return;
    }

    bytes4 selector = extractSelector(errorData);
    
    if (isErrorString(selector)) {
      // 2. require failure case (ex: require(false, "error message"))
      handleRequireFailure(errorData, allowedRequireErrorMessages);
    } else if (allowedCustomErrors.length > 0) {
      // 3. custom error case (ex: MyCustomError())
      handleCustomError(selector, allowedCustomErrors, errorContext);
    } else {
      fl.t(false, "unexpected error type");
    }
  }

  function extractSelector(bytes memory errorData) internal pure returns (bytes4) {
    bytes4 selector;
    assembly {
      // errorData location has length. That's way adding 32 to get actual errorData
      selector := mload(add(errorData, 32))
    }
    return selector;
  }

  function isErrorString(bytes4 selector) internal pure returns (bool) {
    return selector == 0x08c379a0;  // 0x08c379a0 is the selector for "Error(string)" which is the error type for require(...) failure
  }

  function handleEmptyError(bool allowEmptyRequireError) internal {
    fl.t(allowEmptyRequireError, "require failure without message");
  }

  function handleRequireFailure(
    bytes memory errorData,
    bytes[] memory allowedRequireErrorMessages
  ) internal {
    // remove the first 4 bytes which is the selector of the error
    bytes memory strippedData = new bytes(errorData.length - 4);
    
    for (uint i = 0; i < errorData.length - 4; i++) {
      strippedData[i] = errorData[i + 4];
    }

    bool allowed = false;

    for (uint256 i = 0; i < allowedRequireErrorMessages.length; i++) {
      if (keccak256(strippedData) == keccak256(allowedRequireErrorMessages[i])) {
        allowed = true;
        break;
      }
    }

    string memory errorMsg = convertToErrorMessage(strippedData);
    fl.t(allowed, errorMsg);
  }

  function handleCustomError(
    bytes4 selector,
    bytes4[] memory allowedCustomErrors,
    string memory errorContext
  ) internal {
    fl.errAllow(selector, allowedCustomErrors, errorContext);
  }

  function convertToErrorMessage(bytes memory strippedData) internal pure returns (string memory) {
    if (strippedData.length == 0) {
      return "unknown error";
    }
    
    string memory errorMsg;
    assembly {
      errorMsg := add(strippedData, 32)
    }
    return errorMsg;
  }
}
