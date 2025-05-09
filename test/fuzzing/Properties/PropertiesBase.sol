// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@perimetersec/fuzzlib/src/FuzzBase.sol";
import "./PropertiesDescriptions.sol";
import "../BeforeAfter.sol";
import "../helper/utils.sol";

abstract contract PropertiesBase is FuzzBase, PropertiesDescriptions, BeforeAfter, Utils {}
