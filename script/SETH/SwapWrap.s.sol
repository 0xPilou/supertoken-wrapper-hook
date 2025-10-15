// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Hooks } from "@uniswap/v4-core/src/libraries/Hooks.sol";

import { Script } from "forge-std/Script.sol";
import { SETHHook } from "src/SETHHook.sol";

import { IHooks } from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import { CurrencyLibrary } from "@uniswap/v4-core/src/types/Currency.sol";
import { Currency } from "@uniswap/v4-core/src/types/Currency.sol";
import { IERC20 } from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

import { PoolKey } from "@uniswap/v4-core/src/types/PoolKey.sol";
import { IUniswapV4Router04 } from "src/interfaces/IUniswapV4Router04.sol";

contract SwapWrap is Script {

    address public swapRouter = 0xf13D190e9117920c703d79B5F33732e10049b115;
    address public sethHook = 0x18A4278Bf03249A033a114Ee828000E3BADf2888;
    address public seth = 0x30a6933Ca9230361972E413a15dC8114c952414e;
    address public deployer;

    function _startBroadcast() internal returns (address deployerAddress) {
        vm.startBroadcast();

        (, deployerAddress,) = vm.readCallers();
    }

    function _stopBroadcast() internal {
        vm.stopBroadcast();
    }

    function run() public {
        // Start broadcasting transactions
        deployer = _startBroadcast();

        // _upgradeETH(1 ether);
        _downgradeETHx(0.1 ether);

        _stopBroadcast();
    }

    function _upgradeETH(uint256 amount) internal {
        PoolKey memory poolKey = PoolKey({
            currency0: CurrencyLibrary.ADDRESS_ZERO,
            currency1: Currency.wrap(seth),
            fee: 0, // Must be 0 for wrapper pools
            tickSpacing: 60,
            hooks: IHooks(sethHook)
        });

        // Execute swap
        IUniswapV4Router04(swapRouter).swapExactTokensForTokens{ value: amount }({
            amountIn: amount,
            amountOutMin: 0, // allow for unlimited price impact
            zeroForOne: true,
            poolKey: poolKey,
            hookData: "",
            receiver: deployer,
            deadline: block.timestamp + 180
        });
    }

    function _downgradeETHx(uint256 amount) internal {
        PoolKey memory poolKey = PoolKey({
            currency0: CurrencyLibrary.ADDRESS_ZERO,
            currency1: Currency.wrap(seth),
            fee: 0, // Must be 0 for wrapper pools
            tickSpacing: 60,
            hooks: IHooks(sethHook)
        });

        IERC20(seth).approve(address(swapRouter), amount);

        // Execute swap
        IUniswapV4Router04(swapRouter).swapExactTokensForTokens({
            amountIn: amount,
            amountOutMin: 0, // allow for unlimited price impact
            zeroForOne: false,
            poolKey: poolKey,
            hookData: "",
            receiver: deployer,
            deadline: block.timestamp + 180
        });
    }

}
