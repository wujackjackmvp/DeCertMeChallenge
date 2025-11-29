// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./BaseScript.s.sol";
import "../src/LeepCoin.sol";
import "../src/Exchange.sol";

contract DeployAllScript is BaseScript {
    // 默认初始供应量设置为10000个代币
    uint256 public constant INITIAL_SUPPLY = 10000;
    // 默认费率设置为1%
    uint256 public constant FEE_PERCENT = 1;

    function run() public broadcaster {
        console.log("Starting deployment of all contracts...");
        
        // 1. 部署LeepCoin合约
        console.log("Deploying LeepCoin...");
        LeepCoin leepCoin = new LeepCoin(INITIAL_SUPPLY);
        console.log("LeepCoin deployed at:", address(leepCoin));
        saveContract("LeepCoin", address(leepCoin));
        
        // 2. 使用部署者地址作为收费账户部署Exchange合约
        console.log("Deploying Exchange...");
        Exchange exchange = new Exchange(deployer, FEE_PERCENT);
        console.log("Exchange deployed at:", address(exchange));
        console.log("Fee Account:", deployer);
        console.log("Fee Percent:", FEE_PERCENT);
        saveContract("Exchange", address(exchange));
        
        console.log("Deployment completed successfully!");
        console.log("Contract addresses:");
        console.log("- LeepCoin:", address(leepCoin));
        console.log("- Exchange:", address(exchange));
    }
}