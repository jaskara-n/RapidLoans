// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
import {FlashLoanSimpleReceiverBase} from "@aave/core-v3/contracts/flashloan/base/FlashLoanSimpleReceiverBase.sol";
import {IPoolAddressesProvider} from "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";
import {IERC20} from "@aave/core-v3/contracts/interfaces/IERC20WithPermit.sol";

contract BlazeLoans is FlashLoanSimpleReceiverBase {
    constructor(
        address _poolAddressProvider
    )
        FlashLoanSimpleReceiverBase(
            IPoolAddressesProvider(_poolAddressProvider)
        )
    {}

    function requestLoan(address _asset, uint256 _amount) public {
        address asset = _asset;
        uint256 amount = _amount;
        bytes memory params = "";
        uint16 referalcode = 0;
        POOL.flashLoanSimple(address(this), asset, amount, params, referalcode);
    }

    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external override returns (bool) {
        uint256 repayAmount = amount + premium;
        IERC20(asset).approve(address(POOL), repayAmount);
        return true;
    }
}
