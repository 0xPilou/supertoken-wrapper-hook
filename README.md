## Uniswap V4 Hooks for SuperToken upgrading/downgrading

This repository contains the Uniswap V4 hooks for upgrading/downgrading SuperTokens in Uniswap V4 pools.

## Documentation

These hooks are inspired by the [WETHHook](https://github.com/Uniswap/v4-periphery/blob/main/src/hooks/WETHHook.sol) from the Uniswap V4 Periphery repository.

Due to the different types of SuperTokens that Superfluid Protocol offers, it exists two types of hooks:

- SuperTokenWrapperHook : used for Wrapper SuperToken upgrading/downgrading
- SETHHook : used for Native Asset SuperToken upgrading/downgrading

## Requirements

For these hook to work, Uniswap V4 PoolManager contract must hold the SuperToken and the underlying token.
These assets may be provided in any pools.

### Build

```shell
$ forge build
```

### Deploy

#### Deploy SETHHook

```shell
$ forge script script/SETH/DeploySETHHook.s.sol:DeploySETHHook --rpc-url <your_rpc_url> --private-key <your_private_key>
```

#### Deploy SuperTokenWrapperHook

```shell
$ forge script script/wrapper-supertoken/DeploySuperTokenWrapperHook.s.sol:DeploySuperTokenWrapperHook --rpc-url <your_rpc_url> --private-key <your_private_key>
```
