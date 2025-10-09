// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { BaseTokenWrapperHook } from "@uniswap/v4-periphery/src/base/hooks/BaseTokenWrapperHook.sol";

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ISuperToken } from "@superfluid-finance/ethereum-contracts/contracts/superfluid/SuperToken.sol";
import { IPoolManager } from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import { Currency } from "@uniswap/v4-core/src/types/Currency.sol";

/// @title Wrapped SuperToken Hook
/// @notice Hook for upgrading/downgrading SuperToken in Uniswap V4 pools
/// @dev Implements 1:1 upgrading/downgrading a SuperToken to its underlying token
contract SuperTokenWrapperHook is BaseTokenWrapperHook {

    /// @notice The SuperToken contract
    ISuperToken public immutable superToken;

    /// @notice Creates a new SuperToken wrapper hook
    /// @param _manager The Uniswap V4 pool manager
    /// @param _superToken The SuperToken contract address
    constructor(IPoolManager _manager, address _superToken, address _underlyingToken)
        BaseTokenWrapperHook(_manager, Currency.wrap(_superToken), Currency.wrap(_underlyingToken))
    {
        superToken = ISuperToken(_superToken);
    }

    /// @inheritdoc BaseTokenWrapperHook
    function _deposit(uint256 underlyingAmount) internal override returns (uint256, uint256) {
        // Sync WETH on PoolManager
        poolManager.sync(wrapperCurrency);

        // take Underlying Token from PoolManager to this Hook contract
        _take(underlyingCurrency, address(this), underlyingAmount);

        // Approve SuperToken to spend Underlying Token from this Hook contract
        IERC20(Currency.unwrap(underlyingCurrency)).approve(address(superToken), underlyingAmount);

        // Upgrade SuperToken to Underlying Token
        superToken.upgrade(underlyingAmount);

        // Settle on PoolManager which will take into account the new SuperToken
        _settle(wrapperCurrency, address(this), underlyingAmount);

        return (underlyingAmount, underlyingAmount); // 1:1 ratio
    }

    /// @inheritdoc BaseTokenWrapperHook
    function _withdraw(uint256 wrapperAmount) internal override returns (uint256, uint256) {
        // take the SuperToken into this hook contract
        _take(wrapperCurrency, address(this), wrapperAmount);

        // downgrade SuperToken to Underlying Token
        superToken.downgrade(wrapperAmount);

        _settle(underlyingCurrency, address(this), wrapperAmount);
        return (wrapperAmount, wrapperAmount); // 1:1 ratio
    }

    /// @notice Required to receive ETH
    receive() external payable { }

}
