import {Script, console} from "forge-std/Script.sol";
import "../src/RapidLoans.sol";

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

contract MyScript is Script {
    address aave_usdc = 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8;
    uint256 amount = 5 gwei;
    address contractAddress = 0xfb4561C6AFF45c00EE0D2eF33D058E2F96959f0F;

    function request() public payable {
        vm.startBroadcast();
        RapidLoans(payable(contractAddress)).requestLoan(aave_usdc, amount, 1);
        vm.stopBroadcast();
        console.log("yolo");
    }

    function run() external {
        request();
    }
}
