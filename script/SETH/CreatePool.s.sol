// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Hooks } from "@uniswap/v4-core/src/libraries/Hooks.sol";

import { IPoolManager } from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import { Script } from "forge-std/Script.sol";
import { NetworkConfig } from "script/config/NetworkConfig.sol";
import { SETHHook } from "src/SETHHook.sol";

import { IHooks } from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import { TickMath } from "@uniswap/v4-core/src/libraries/TickMath.sol";
import { CurrencyLibrary } from "@uniswap/v4-core/src/types/Currency.sol";
import { Currency } from "@uniswap/v4-core/src/types/Currency.sol";

import { PoolKey } from "@uniswap/v4-core/src/types/PoolKey.sol";

contract CreateETHxPool is Script {

    function run() public {
        uint256 chainId = block.chainid;

        NetworkConfig.DeploymentConfig memory config = NetworkConfig.getNetworkConfig(chainId);

        address sethHook = 0x18A4278Bf03249A033a114Ee828000E3BADf2888;

        // Start broadcasting transactions
        vm.startBroadcast();

        // Create the UniswapV4 Pool for ETHx/ETH
        _createPool(sethHook, config);

        vm.stopBroadcast();
    }

    function _createPool(address hook, NetworkConfig.DeploymentConfig memory config) internal {
        // Create pool key for ETHx/ETH
        PoolKey memory poolKey = PoolKey({
            currency0: CurrencyLibrary.ADDRESS_ZERO,
            currency1: Currency.wrap(address(config.seth)),
            fee: 0, // Must be 0 for wrapper pools
            tickSpacing: 60,
            hooks: IHooks(hook)
        });

        // Initialize pool at 1:1 price
        uint160 initSqrtPriceX96 = uint160(TickMath.getSqrtPriceAtTick(0));
        IPoolManager(config.poolManager).initialize(poolKey, initSqrtPriceX96);
    }

}
