// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
// import {MockFlashLoanSimpleReceiver} from "@aave/core-v3/contracts/mocks/flashloan/MockSimpleFlashLoanReceiver.sol";
// import {IFlashLoanSimpleReceiver} from "@aave/core-v3/contracts/interfaces/IFlashLoanSimpleReceiver.sol";
import {FlashLoanSimpleReceiverBase} from "@aave/core-v3/contracts/flashloan/base/FlashLoanSimpleReceiverBase.sol";
import {IPoolAddressesProvider} from "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";
import {IERC20} from "@aave/core-v3/contracts/interfaces/IERC20WithPermit.sol";

contract RapidLoans is FlashLoanSimpleReceiverBase {
    uint256 public counter;
    address public poolAddressProv;

    event loanRequested(address asset, uint256 amount, uint256 typ);
    event loanExecuted(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator
    );

    constructor(
        address _poolAddressProvider
    )
        FlashLoanSimpleReceiverBase(
            IPoolAddressesProvider(_poolAddressProvider)
        )
    {
        poolAddressProv = _poolAddressProvider;
    }

    /**
     * @notice request a flash loan using aave protocol v3
     * @param _asset principal asset
     * @param _amount amount of principal asset
     * @param _type type of flashloan service
     * @notice type=1 for refinancing a loan on other exchange, type=2 for swapping collateral of underlying loan, type=3 to protect liquidation
     */

    function requestLoan(
        address _asset,
        uint256 _amount,
        uint256 _type
    ) public {
        if (_type == 1) {
            refinanceLoan();
        } else if (_type == 2) {
            swapCollateral();
        } else {
            protectLiquidation();
        }
        address asset = _asset;
        uint256 amount = _amount;
        uint typ = _type;
        bytes memory params = "";
        uint16 referalcode = 0;
        POOL.flashLoanSimple(address(this), asset, amount, params, referalcode);
        emit loanRequested(asset, amount, typ);
        counter++;
    }

    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external override returns (bool) {
        // deductPremiumFromUser(initiator, premium, asset);
        uint256 repayAmount = amount + premium;
        IERC20(asset).approve(address(POOL), repayAmount);
        emit loanExecuted(asset, amount, premium, initiator);
        return true;
    }

    function deductPremiumFromUser(
        address initiator,
        uint256 premium,
        address asset
    ) internal {
        IERC20(asset).approve(initiator, premium);
        require(
            IERC20(asset).allowance(address(this), initiator) >= premium,
            "approve tokens!!"
        );
        IERC20(asset).transferFrom(initiator, address(this), premium);
    }

    function refinanceLoan() internal {}

    function swapCollateral() internal {}

    function protectLiquidation() internal {}

    function getPoolAddress() public view returns (address) {
        return poolAddressProv;
    }

    function getContractTokenBal(
        address tokenAdd
    ) public view returns (uint256) {
        return IERC20(tokenAdd).balanceOf(address(this));
    }

    receive() external payable {}
}
