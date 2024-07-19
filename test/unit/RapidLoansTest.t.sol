// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;
import {RapidLoans} from "../../src/RapidLoans.sol";
import {IERC20} from "@aave/core-v3/contracts/interfaces/IERC20WithPermit.sol";
// import {ERC20} from "protocol-v3/contracts/dependencies/openzeppelin/contracts/ERC20.sol";
import {MyScript} from "../../script/RapidLoans.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {Script} from "forge-std/Script.sol";

contract RapidLoansTest is StdCheats, Test, Script {
    uint256 public constant STARTING_USER_BALANCE = 10 ether;
    uint256 public constant FUND_VALUE = 0.1 ether; // just a value to make sure we are sending enough!
    uint256 public constant AMOUNT = 5;
    uint256 public constant TYPE = 1;
    event loanRequested(address asset, uint256 amount, uint256 typ);
    RapidLoans public loan;
    HelperConfig public helperConfig;
    address public constant USER = address(1);
    address public constant USER2 = address(2);

    function setUp() external {
        // console.log("started");
        MyScript myscript = new MyScript();
        HelperConfig _helperConfig = new HelperConfig();
        helperConfig = _helperConfig;
        // console.log("process");
        (loan) = myscript.run();
        // console.log("ended");
        vm.deal(USER, STARTING_USER_BALANCE);
        vm.deal(USER2, STARTING_USER_BALANCE);
        // vm.startPrank(USER);
        // // vm.startBroadcast();
        // loan.fund{value: FUND_VALUE}();
        // // vm.stopBroadcast();
        // vm.stopPrank();
    }

    function testIfDeployingCorrectly() public {
        address pool2;
        address pool = helperConfig.getActiveConfig().poolAddressProvider;
        console.log("address 1 = ", pool);
        pool2 = loan.getPoolAddress();
        console.log("address 2 = ", pool2);
        assertEq(pool, pool2);
        // assertEq(address(loan), address(loan));
    }

    // function testIfFunded() public {
    //     uint256 startingContractBalance = address(loan).balance;
    //     console.log(STARTING_USER_BALANCE);
    //     // vm.startBroadcast();
    //     vm.startPrank(USER2);
    //     loan.fund{value: FUND_VALUE}();
    //     vm.stopPrank();
    //     // vm.stopBroadcast();

    //     uint256 endingContractBalance = address(loan).balance;
    //     console.log(endingContractBalance);
    //     assertGt(endingContractBalance, startingContractBalance);
    // }

    function testifEmitloanRequested() public {
        address token = helperConfig.getActiveConfig().USDT;
        vm.expectEmit(false, false, false, true, address(loan));
        emit loanRequested(token, AMOUNT, TYPE);
        console.log(token);
        vm.startPrank(USER2);
        loan.requestLoan(token, AMOUNT, TYPE);
        vm.stopPrank();
    }

    function testifPremiumDeducted() public {
        address token = helperConfig.getActiveConfig().USDT;
        uint256 startingContractBal = IERC20(token).balanceOf(address(USER2));
        // IERC20(token)._mint(USER2, 100);
        vm.startPrank(USER2);
        loan.requestLoan(token, 3, 1);
        vm.stopPrank;
        uint256 endingContractBal = IERC20(token).balanceOf(USER2);
        assertLt(startingContractBal, endingContractBal);
    }

    function testIfLoanGoingThrough() public {}
}
