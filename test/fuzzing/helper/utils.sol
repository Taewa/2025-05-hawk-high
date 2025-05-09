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

  // TODO: update fn name
  // TODO: (failedData.length == 4) is not always true for Panic(string). Need to find a way to handle it. Panic(string) vs Error(string)
  function allowRequire(  
    bytes memory failedData,
    bytes[] memory allowedErrorMessages,
    bytes4[] memory allowedErrors,
    string memory errorContext
  ) internal {
    bytes memory strippedData;
    bool allowed = false;

    // 4 bytes are removed from the beginning of the data (4 bytes are the selector of the function. in this case, it's Error(string))
    if (failedData.length > 4) {
      strippedData = new bytes(failedData.length - 4);
      for (uint i = 0; i < failedData.length - 4; i++) {
        strippedData[i] = failedData[i + 4];
      }
    } else if (failedData.length == 4) {
      // If we have allowedErrors, check for custom errors
      if (allowedErrors.length > 0) {
        fl.errAllow(bytes4(failedData), allowedErrors, errorContext);
        return;
      }
      strippedData = "";
    } else {
      strippedData = failedData;
    }

    for (uint256 i = 0; i < allowedErrorMessages.length; i++) {
      if (keccak256(strippedData) == keccak256(allowedErrorMessages[i])) {
        allowed = true;
        break;
      }
    }

    // string conversion attempt, if failed, replace with "unknown error"
    string memory errorMsg;
    if (strippedData.length == 0) {
      errorMsg = "unknown error";
    } else {
      // try-catch is only available for external calls, so defensively handle it
      // when converting bytes to string, invalid UTF-8 may cause panic
      // so convert it safely using assembly
      assembly {
        errorMsg := add(strippedData, 0x20)
      }
    }

    fl.t(allowed, errorMsg);
  }

  function toHexString(bytes memory data) internal pure returns (string memory) {
    bytes memory alphabet = "0123456789abcdef";
    bytes memory str = new bytes(2 + data.length * 2);
    str[0] = "0";
    str[1] = "x";
    for (uint256 i = 0; i < data.length; i++) {
        str[2 + i * 2] = alphabet[uint8(data[i] >> 4)];
        str[3 + i * 2] = alphabet[uint8(data[i] & 0x0f)];
    }
    return string(str);
  }
}
