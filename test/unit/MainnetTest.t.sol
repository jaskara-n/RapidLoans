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
    HelperConfig helperConfig;
    RapidLoans rapidLoans;
    IERC20 usdc;
    uint256 mainnetFork;
    address user = address(124);
    string MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");

    event loanExecuted(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator
    );
    event loanRequested(address asset, uint256 amount, uint256 typ);

    function setUp() external {
        mainnetFork = vm.createFork(MAINNET_RPC_URL);
        HelperConfig _helperConfig = new HelperConfig();
        helperConfig = _helperConfig;
        address pooolAddressProvider = helperConfig
            .getMainnetConfig()
            .poolAddressProvider;
        usdc = IERC20(helperConfig.getMainnetConfig().USDT);
        vm.selectFork(mainnetFork);
        rapidLoans = new RapidLoans(pooolAddressProvider);
        deal(address(usdc), user, 1e6 * 50, true);
        deal(address(usdc), address(rapidLoans), 1e6 * 80);
    }

    function testIfPremiumDeductedFromContract() public {
        uint256 startingTokenBalance = usdc.balanceOf(address(rapidLoans));
        rapidLoans.requestLoan(address(usdc), 1e6 * 70, 1);
        uint256 endingContractBalance = usdc.balanceOf(address(rapidLoans));
        assertLt(endingContractBalance, startingTokenBalance);
    }

    function testifEmitloanRequested() public {
        vm.expectEmit(false, false, false, true, address(rapidLoans));
        emit loanRequested(address(usdc), 1e6 * 70, 1);
        vm.startPrank(user);
        rapidLoans.requestLoan(address(usdc), 1e6 * 70, 1);
        vm.stopPrank();
    }
}
