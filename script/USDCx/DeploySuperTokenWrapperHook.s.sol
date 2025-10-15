// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IHooks } from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import { IPoolManager } from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import { Hooks } from "@uniswap/v4-core/src/libraries/Hooks.sol";

import { TickMath } from "@uniswap/v4-core/src/libraries/TickMath.sol";
import { Currency } from "@uniswap/v4-core/src/types/Currency.sol";
import { PoolKey } from "@uniswap/v4-core/src/types/PoolKey.sol";
import { HookMiner } from "@uniswap/v4-periphery/src/utils/HookMiner.sol";
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { NetworkConfig } from "script/config/NetworkConfig.sol";
import { SuperTokenWrapperHook } from "src/SuperTokenWrapperHook.sol";

/// @notice Mines the address and deploys the SuperTokenWrapperHook.sol Hook contract
contract DeploySuperTokenWrapperHookScript is Script {

    function _startBroadcast() internal returns (address deployer) {
        vm.startBroadcast();

        (, deployer,) = vm.readCallers();
    }

    function _stopBroadcast() internal {
        vm.stopBroadcast();
    }

    function run() public {
        uint256 chainId = block.chainid;

        NetworkConfig.DeploymentConfig memory config = NetworkConfig.getNetworkConfig(chainId);

        console.log("");
        console.log("===> DEPLOYMENT CONFIGURATION");
        console.log(" --- UniswapV4 Position Manager    :", config.positionManager);
        console.log(" --- UniswapV4 Pool Manager        :", config.poolManager);
        console.log(" --- Permit2 address               :", config.permit2);
        console.log(" --- fUSDC address                  :", config.usdc);
        console.log(" --- fUSDCx address                  :", config.usdcx);

        // hook contracts must have specific flags encoded in the address
        uint160 flags = uint160(
            Hooks.BEFORE_INITIALIZE_FLAG | Hooks.BEFORE_ADD_LIQUIDITY_FLAG | Hooks.BEFORE_SWAP_FLAG
                | Hooks.BEFORE_SWAP_RETURNS_DELTA_FLAG
        );

        // Mine a salt that will produce a hook address with the correct flags
        bytes memory constructorArgs = abi.encode(IPoolManager(config.poolManager), config.usdcx, config.usdc);

        (address hookAddress, bytes32 salt) =
            HookMiner.find(CREATE2_FACTORY, flags, type(SuperTokenWrapperHook).creationCode, constructorArgs);

        // Start broadcasting transactions
        address deployer = _startBroadcast();
        console.log("");
        console.log("===> DEPLOYING SuperTokenWrapperHook");
        console.log(" --- Chain ID          :   ", chainId);
        console.log(" --- Deployer address  :   ", deployer);
        console.log(" --- Deployer balance  :   ", deployer.balance / 1e18, "ETH");

        // Deploy the hook using CREATE2
        SuperTokenWrapperHook stHook =
            new SuperTokenWrapperHook{ salt: salt }(IPoolManager(config.poolManager), config.usdcx, config.usdc);
        _stopBroadcast();

        require(address(stHook) == hookAddress, "DeployHookScript: Hook Address Mismatch");

        _createPool(address(stHook), config);

        console.log("");
        console.log("===> DEPLOYMENT RESULTS");
        console.log(" --- SuperTokenWrapperHook            :", address(stHook));
        console.log("");
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
