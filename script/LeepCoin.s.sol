// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./BaseScript.s.sol";
import "../src/LeepCoin.sol";

contract LeepCoinScript is BaseScript {
    // 默认初始供应量设置为10000个代币
    uint256 public constant INITIAL_SUPPLY = 10000;

    function run() public broadcaster {
        console.log("Deploying LeepCoin...");
        
        // 部署LeepCoin合约，传入初始供应量
        LeepCoin leepCoin = new LeepCoin(INITIAL_SUPPLY);
        
        console.log("LeepCoin deployed at:", address(leepCoin));
        
        // 保存部署信息到文件
        saveContract("LeepCoin", address(leepCoin));
    }
}