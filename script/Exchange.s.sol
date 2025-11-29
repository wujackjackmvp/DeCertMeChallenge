// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./BaseScript.s.sol";
import "../src/Exchange.sol";
import "../src/LeepCoin.sol";

contract ExchangeScript is BaseScript {
    // 默认费率设置为1%
    uint256 public constant FEE_PERCENT = 1;

    function run() public broadcaster {
        console.log("Deploying Exchange...");
        
        // 使用部署者地址作为收费账户
        address feeAccount = deployer;
        
        // 部署Exchange合约，传入收费账户地址和费率
        Exchange exchange = new Exchange(feeAccount, FEE_PERCENT);
        
        console.log("Exchange deployed at:", address(exchange));
        console.log("Fee Account:", feeAccount);
        console.log("Fee Percent:", FEE_PERCENT);
        
        // 保存部署信息到文件
        saveContract("Exchange", address(exchange));
    }
    
    // 单独部署LeepCoin和Exchange的函数
    function deployLeepCoin() public broadcaster returns (LeepCoin) {
        console.log("Deploying LeepCoin...");
        LeepCoin leepCoin = new LeepCoin(10000); // 10000个代币
        console.log("LeepCoin deployed at:", address(leepCoin));
        saveContract("LeepCoin", address(leepCoin));
        return leepCoin;
    }
    
    function deployExchange(address _feeAccount) public broadcaster returns (Exchange) {
        console.log("Deploying Exchange...");
        Exchange exchange = new Exchange(_feeAccount, FEE_PERCENT);
        console.log("Exchange deployed at:", address(exchange));
        console.log("Fee Account:", _feeAccount);
        console.log("Fee Percent:", FEE_PERCENT);
        saveContract("Exchange", address(exchange));
        return exchange;
    }
}