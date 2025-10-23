// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IPoolManager } from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import { Hooks } from "@uniswap/v4-core/src/libraries/Hooks.sol";
import { HookMiner } from "@uniswap/v4-periphery/src/utils/HookMiner.sol";
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { NetworkConfig } from "script/config/NetworkConfig.sol";
import { SETHHook } from "src/SETHHook.sol";

/// @notice Mines the address and deploys the SETHHook.sol Hook contract
contract DeployHookScript is Script {

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
        console.log(" --- SETH address                  :", config.seth);

        // hook contracts must have specific flags encoded in the address
        uint160 flags = uint160(
            Hooks.BEFORE_INITIALIZE_FLAG | Hooks.BEFORE_ADD_LIQUIDITY_FLAG | Hooks.BEFORE_SWAP_FLAG
                | Hooks.BEFORE_SWAP_RETURNS_DELTA_FLAG
        );

        // Mine a salt that will produce a hook address with the correct flags
        bytes memory constructorArgs = abi.encode(IPoolManager(config.poolManager), config.seth);

        (address hookAddress, bytes32 salt) =
            HookMiner.find(CREATE2_FACTORY, flags, type(SETHHook).creationCode, constructorArgs);

        // Start broadcasting transactions
        address deployer = _startBroadcast();
        console.log("");
        console.log("===> DEPLOYING SETHHook");
        console.log(" --- Chain ID          :   ", chainId);
        console.log(" --- Deployer address  :   ", deployer);
        console.log(" --- Deployer balance  :   ", deployer.balance / 1e18, "ETH");

        // Deploy the hook using CREATE2
        SETHHook sethHook = new SETHHook{ salt: salt }(IPoolManager(config.poolManager), config.seth);
        _stopBroadcast();

        require(address(sethHook) == hookAddress, "DeployHookScript: Hook Address Mismatch");

        console.log("");
        console.log("===> DEPLOYMENT RESULTS");
        console.log(" --- SETHHook            :", address(sethHook));
        console.log("");
    }

}
