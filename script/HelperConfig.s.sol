//SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/Test.sol";

contract HelperConfig is Script {
    NetworkConfig public ActiveConfig;

    struct NetworkConfig {
        address poolAddressProvider;
        address USDT;
    }

    constructor() {
        if (block.chainid == 11155111) {
            ActiveConfig = getSepoliaConfig();
        } else {
            ActiveConfig = getAnvilConfig();
        }
    }

    // function run() external {
    //     address b = getActiveAddress();
    //     console.log(b);
    // }

    function getSepoliaConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            poolAddressProvider: 0x012bAC54348C0E635dCAc9D5FB99f06F24136C9A,
            USDT: 0xaA8E23Fb1079EA71e0a56F48a2aA51851D8433D0
        });
        return sepoliaConfig;
    }

    function getMainnetConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory mainnetConfig = NetworkConfig({
            poolAddressProvider: 0x2f39d218133AFaB8F2B819B1066c7E434Ad94E9e,
            USDT: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
        });
        return mainnetConfig;
    }

    function getAnvilConfig() public returns (NetworkConfig memory) {
        if (ActiveConfig.poolAddressProvider != address(0)) {
            return ActiveConfig;
        }
        NetworkConfig memory anvilConfig = NetworkConfig({
            poolAddressProvider: 0x012bAC54348C0E635dCAc9D5FB99f06F24136C9A,
            USDT: 0xaA8E23Fb1079EA71e0a56F48a2aA51851D8433D0
        });
        return anvilConfig;
    }

    function getActiveConfig() public view returns (NetworkConfig memory) {
        return ActiveConfig;
    }

    function getActiveAddress() public view returns (address) {
        address a = ActiveConfig.poolAddressProvider;
        return a;
    }
}
