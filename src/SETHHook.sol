// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { BaseTokenWrapperHook } from "@uniswap/v4-periphery/src/base/hooks/BaseTokenWrapperHook.sol";

import { ISETH } from "@superfluid-finance/ethereum-contracts/contracts/interfaces/tokens/ISETH.sol";
import { IPoolManager } from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import { Currency, CurrencyLibrary } from "@uniswap/v4-core/src/types/Currency.sol";

/**
 * @title Native Asset SuperToken Hook
 * @author Superfluid
 * @notice Hook for upgrading/downgrading SuperToken in Uniswap V4 pools
 * @dev Implements 1:1 upgrading/downgrading a SuperToken to/from its underlying token
 */
contract SETHHook is BaseTokenWrapperHook {

    /// @notice The Native Asset SuperToken contract address (SETH)
    ISETH public immutable seth;

    /**
     * @notice Creates a new SuperToken wrapper hook
     * @param _manager The Uniswap V4 pool manager
     * @param _seth The SETH contract address
     */
    constructor(IPoolManager _manager, address _seth)
        BaseTokenWrapperHook(_manager, Currency.wrap(_seth), CurrencyLibrary.ADDRESS_ZERO)
    {
        seth = ISETH(payable(_seth));
    }

    /// @inheritdoc BaseTokenWrapperHook
    function _deposit(uint256 underlyingAmount) internal override returns (uint256, uint256) {
        // Sync ETHx on PoolManager
        poolManager.sync(wrapperCurrency);

        // Take Underlying Token from PoolManager to the wrapper contract
        // (this work because SETH contract has a receive function that calls upgradeByETH)
        _take(underlyingCurrency, address(seth), underlyingAmount);

        // Settle on PoolManager which will take into account the new SuperToken
        poolManager.settle();

        return (underlyingAmount, underlyingAmount); // 1:1 ratio
    }

    /// @inheritdoc BaseTokenWrapperHook
    function _withdraw(uint256 wrapperAmount) internal override returns (uint256, uint256) {
        // take the SuperToken from the PoolManager into this hook contract
        _take(wrapperCurrency, address(this), wrapperAmount);

        // downgrade SuperToken to Underlying Token
        seth.downgradeToETH(wrapperAmount);

        _settle(underlyingCurrency, address(this), wrapperAmount);
        return (wrapperAmount, wrapperAmount); // 1:1 ratio
    }

    /// @notice Required to receive ETH
    receive() external payable { }

}
