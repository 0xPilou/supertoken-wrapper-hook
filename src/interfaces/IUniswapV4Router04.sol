// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { PoolKey } from "@uniswap/v4-core/src/types/PoolKey.sol";

/// @title Uniswap V4 Swap Router
/// @notice A simple, stateless router for execution of swaps against Uniswap v4 Pools
/// @dev ABI inspired by UniswapV2Router02
interface IUniswapV4Router04 {

    /// ================ SINGLE POOL SWAPS ================ ///

    /// @notice Single pool, exact input swap - swap the specified amount of input tokens for as many output tokens as
    /// possible, on a single pool
    /// @param amountIn the amount of input tokens to swap
    /// @param amountOutMin the minimum amount of output tokens that must be received for the transaction not to revert
    /// @param zeroForOne the direction of the swap, true if currency0 is being swapped for currency1
    /// @param poolKey the pool to swap through
    /// @param hookData the data to be passed to the hook
    /// @param receiver the address to send the output tokens to
    /// @param deadline block.timestamp must be before this value, otherwise the transaction will revert
    /// @return Delta the balance changes from the swap
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        bool zeroForOne,
        PoolKey calldata poolKey,
        bytes calldata hookData,
        address receiver,
        uint256 deadline
    ) external payable returns (int256);

}
