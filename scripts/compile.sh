#!/bin/bash

truffle compile

mkdir -p build/abi/json
solc contracts/Staking.sol --abi --include-path="node_modules" --base-path="." --output-dir="build/abi/json" --overwrite
solc contracts/ERC20Mock.sol --abi --include-path="node_modules" --base-path="." --output-dir="build/abi/json" --overwrite

mkdir -p build/abi/go
./tools/abigen --abi="build/abi/json/Staking.abi" --type="Staking" --pkg="contract" --out="build/abi/go/staking.go"
./tools/abigen --abi="build/abi/json/ERC20Mock.abi" --type="ERC20Mock" --pkg="contract" --out="build/abi/go/erc20_mock.go"
