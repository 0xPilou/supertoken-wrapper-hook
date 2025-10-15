// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Hooks } from "@uniswap/v4-core/src/libraries/Hooks.sol";
import { Script } from "forge-std/Script.sol";

import { IHooks } from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import { Currency } from "@uniswap/v4-core/src/types/Currency.sol";

import { PoolKey } from "@uniswap/v4-core/src/types/PoolKey.sol";
import { IERC20 } from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import { IUniswapV4Router04 } from "src/interfaces/IUniswapV4Router04.sol";

contract SwapWrapUSDC is Script {

    address public swapRouter = 0xf13D190e9117920c703d79B5F33732e10049b115;
    address public usdcxHook = 0x25Fedf8335Ae23FAC39fA1a0e798dfb07730a888;
    address public usdcx = 0xb598E6C621618a9f63788816ffb50Ee2862D443B;
    address public usdc = 0xe72f289584eDA2bE69Cfe487f4638F09bAc920Db;
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
        _upgradeUSDCx(5000 ether);

        _stopBroadcast();
    }

    function _upgradeUSDCx(uint256 amount) internal {
        bool usdcIsZero = usdc < usdcx;

        Currency currency0 = usdcIsZero ? Currency.wrap(usdc) : Currency.wrap(usdcx);
        Currency currency1 = usdcIsZero ? Currency.wrap(usdcx) : Currency.wrap(usdc);

        PoolKey memory poolKey =
            PoolKey({ currency0: currency0, currency1: currency1, fee: 0, tickSpacing: 60, hooks: IHooks(usdcxHook) });

        IERC20(usdc).approve(address(swapRouter), amount);

        // Execute swap
        IUniswapV4Router04(swapRouter).swapExactTokensForTokens({
            amountIn: amount,
            amountOutMin: 0, // allow for unlimited price impact
            zeroForOne: usdcIsZero,
            poolKey: poolKey,
            hookData: "",
            receiver: deployer,
            deadline: block.timestamp + 180
        });
    }

    function _downgradeUSDCx(uint256 amount) internal {
        bool usdcIsZero = usdc < usdcx;

        Currency currency0 = usdcIsZero ? Currency.wrap(usdc) : Currency.wrap(usdcx);
        Currency currency1 = usdcIsZero ? Currency.wrap(usdcx) : Currency.wrap(usdc);

        PoolKey memory poolKey =
            PoolKey({ currency0: currency0, currency1: currency1, fee: 0, tickSpacing: 60, hooks: IHooks(usdcxHook) });

        IERC20(usdcx).approve(address(swapRouter), amount);

        // Execute swap
        IUniswapV4Router04(swapRouter).swapExactTokensForTokens({
            amountIn: amount,
            amountOutMin: 0, // allow for unlimited price impact
            zeroForOne: !usdcIsZero,
            poolKey: poolKey,
            hookData: "",
            receiver: deployer,
            deadline: block.timestamp + 180
        });
    }

}
