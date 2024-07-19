// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {Script, console} from "forge-std/Script.sol";
import "../src/RapidLoans.sol";
import "forge-std/console.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract MyScript is Script {
    function run() external returns (RapidLoans) {
        HelperConfig helperConfig = new HelperConfig();
        address pooolAddressProvider = helperConfig
            .getActiveConfig()
            .poolAddressProvider;
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        console.log(deployerPrivateKey);

        RapidLoans loan = new RapidLoans(pooolAddressProvider);

        vm.stopBroadcast();
        console.log("Contract Address", address(loan));
        return loan;
    }
}
