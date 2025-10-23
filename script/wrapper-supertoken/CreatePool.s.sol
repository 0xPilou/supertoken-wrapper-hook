// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IHooks } from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import { IPoolManager } from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import { Hooks } from "@uniswap/v4-core/src/libraries/Hooks.sol";

import { TickMath } from "@uniswap/v4-core/src/libraries/TickMath.sol";
import { Currency } from "@uniswap/v4-core/src/types/Currency.sol";
import { PoolKey } from "@uniswap/v4-core/src/types/PoolKey.sol";
import { Script } from "forge-std/Script.sol";
import { NetworkConfig } from "script/config/NetworkConfig.sol";

contract CreateUSDCxPool is Script {

    function run() public {
        uint256 chainId = block.chainid;

        NetworkConfig.DeploymentConfig memory config = NetworkConfig.getNetworkConfig(chainId);

        address usdcxHook = 0x8496cB739250cdf3F767b9A993D8179750d82888;

        // Start broadcasting transactions
        vm.startBroadcast();

        _createPool(usdcxHook, config);

        vm.stopBroadcast();
    }

    function _createPool(address hook, NetworkConfig.DeploymentConfig memory config) internal {
        Currency currency0 =
            config.usdc < config.usdcx ? Currency.wrap(address(config.usdc)) : Currency.wrap(address(config.usdcx));
        Currency currency1 =
            config.usdc < config.usdcx ? Currency.wrap(address(config.usdcx)) : Currency.wrap(address(config.usdc));

        // Create pool key for USDC/USDCx
        PoolKey memory poolKey = PoolKey({
            currency0: currency0,
            currency1: currency1,
            fee: 0, // Must be 0 for wrapper pools
            tickSpacing: 60,
            hooks: IHooks(hook)
        });

        // Initialize pool at 1:1 price
        uint160 initSqrtPriceX96 = uint160(TickMath.getSqrtPriceAtTick(0));
        IPoolManager(config.poolManager).initialize(poolKey, initSqrtPriceX96);
    }

}
