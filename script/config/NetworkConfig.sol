// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

library NetworkConfig {

    struct DeploymentConfig {
        address positionManager;
        address poolManager;
        address permit2;
        address seth;
        address usdc;
        address usdcx;
    }

    function getNetworkConfig(uint256 chainId) internal pure returns (DeploymentConfig memory config) {
        if (chainId == 8453) {
            config = getBaseMainnetConfig();
        } else if (chainId == 84_532) {
            config = getBaseSepoliaConfig();
        } else if (chainId == 11_155_111) {
            config = getEthereumSepoliaConfig();
        } else {
            revert("Unsupported chainId");
        }
    }

    /**
     * @dev Get Base Mainnet configuration
     */
    function getBaseMainnetConfig() internal pure returns (DeploymentConfig memory) {
        return DeploymentConfig({
            positionManager: 0x7C5f5A4bBd8fD63184577525326123B519429bDc,
            poolManager: 0x498581fF718922c3f8e6A244956aF099B2652b2b,
            permit2: 0x000000000022D473030F116dDEE9F6B43aC78BA3,
            seth: address(0),
            usdc: address(0),
            usdcx: address(0)
        });
    }

    function getLocalConfig() internal pure returns (DeploymentConfig memory) {
        return getBaseMainnetConfig();
    }

    /**
     * @dev Get Base Sepolia configuration
     */
    function getBaseSepoliaConfig() internal pure returns (DeploymentConfig memory) {
        return DeploymentConfig({
            positionManager: 0x4B2C77d209D3405F41a037Ec6c77F7F5b8e2ca80,
            poolManager: 0x05E73354cFDd6745C338b50BcFDfA3Aa6fA03408,
            permit2: 0x000000000022D473030F116dDEE9F6B43aC78BA3,
            seth: address(0),
            usdc: address(0),
            usdcx: address(0)
        });
    }

    /**
     * @dev Get Ethereum Sepolia configuration
     */
    function getEthereumSepoliaConfig() internal pure returns (DeploymentConfig memory) {
        return DeploymentConfig({
            positionManager: 0x429ba70129df741B2Ca2a85BC3A2a3328e5c09b4,
            poolManager: 0xE03A1074c86CFeDd5C142C4F04F1a1536e203543,
            permit2: 0x000000000022D473030F116dDEE9F6B43aC78BA3,
            seth: 0x30a6933Ca9230361972E413a15dC8114c952414e,
            usdc: 0xe72f289584eDA2bE69Cfe487f4638F09bAc920Db,
            usdcx: 0xb598E6C621618a9f63788816ffb50Ee2862D443B
        });
    }

}
