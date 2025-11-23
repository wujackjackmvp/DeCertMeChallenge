// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {TransferExamples} from "../src/TransferExamples.sol";

/**
 * @title 转账示例测试合约
 * @dev 测试TransferExamples合约中的转账功能
 */
contract TransferExamplesTest is Test {
    TransferExamples public transferContract;
    address payable public testUser;
    uint256 public initialBalance = 1 ether;

    /**
     * @dev 测试设置函数，在每个测试前运行
     */
    function setUp() public {
        // 创建转账合约并初始化余额
        transferContract = new TransferExamples{value: initialBalance}();
        
        // 创建测试用户地址
        testUser = payable(address(new TestUser()));
    }

    /**
     * @dev 测试余额查询功能
     */
    function test_GetBalance() public {
        // 验证合约初始余额
        assertEq(transferContract.getContractBalance(), initialBalance, "合约初始余额应该正确");
        
        // 验证地址余额查询
        assertEq(transferContract.getAddressBalance(address(transferContract)), initialBalance, "地址余额查询应该正确");
    }

    /**
     * @dev 测试transfer转账功能
     */
    function test_TransferEther() public {
        uint256 transferAmount = 0.1 ether;
        uint256 initialUserBalance = testUser.balance;
        uint256 initialContractBalance = transferContract.getContractBalance();
        
        // 执行转账
        transferContract.transferEther(testUser, transferAmount);
        
        // 验证转账结果
        assertEq(testUser.balance, initialUserBalance + transferAmount, "接收方余额应该增加");
        assertEq(transferContract.getContractBalance(), initialContractBalance - transferAmount, "合约余额应该减少");
    }

    /**
     * @dev 测试send转账功能
     */
    function test_SendEther() public {
        uint256 sendAmount = 0.2 ether;
        uint256 initialUserBalance = testUser.balance;
        uint256 initialContractBalance = transferContract.getContractBalance();
        
        // 执行转账
        bool success = transferContract.sendEther(testUser, sendAmount);
        
        // 验证转账成功
        assertTrue(success, "send转账应该成功");
        assertEq(testUser.balance, initialUserBalance + sendAmount, "接收方余额应该增加");
        assertEq(transferContract.getContractBalance(), initialContractBalance - sendAmount, "合约余额应该减少");
    }

    /**
     * @dev 测试call.value转账功能
     */
    function test_CallEther() public {
        uint256 callAmount = 0.3 ether;
        uint256 initialUserBalance = testUser.balance;
        uint256 initialContractBalance = transferContract.getContractBalance();
        bytes memory emptyData = "";
        
        // 执行转账
        bool success = transferContract.callEther(testUser, callAmount, emptyData);
        
        // 验证转账成功
        assertTrue(success, "call转账应该成功");
        assertEq(testUser.balance, initialUserBalance + callAmount, "接收方余额应该增加");
        assertEq(transferContract.getContractBalance(), initialContractBalance - callAmount, "合约余额应该减少");
    }

    /**
     * @dev 测试存款功能
     */
    function test_Deposit() public {
        uint256 depositAmount = 0.5 ether;
        uint256 initialContractBalance = transferContract.getContractBalance();
        
        // 向合约存款
        (bool success, ) = address(transferContract).call{value: depositAmount}(abi.encodeWithSignature("deposit()"));
        assertTrue(success, "存款应该成功");
        
        // 验证存款结果
        assertEq(transferContract.getContractBalance(), initialContractBalance + depositAmount, "合约余额应该增加");
    }

    /**
     * @dev 测试比较三种转账方式
     */
    function test_CompareTransferMethods() public {
        uint256 transferAmount = 0.05 ether;
        uint256 initialUserBalance = testUser.balance;
        
        // 确保合约有足够余额进行三次转账
        uint256 requiredBalance = transferAmount * 3;
        if (transferContract.getContractBalance() < requiredBalance) {
            // 补充存款
            uint256 depositAmount = requiredBalance - transferContract.getContractBalance();
            (bool success, ) = address(transferContract).call{value: depositAmount}(abi.encodeWithSignature("deposit()"));
            assertTrue(success, "补充存款应该成功");
        }
        
        // 调用比较函数
        (bool transferResult, bool sendResult, bool callResult) = transferContract.compareTransferMethods(testUser, transferAmount);
        
        // 验证所有转账方式都成功
        assertTrue(transferResult, "transfer应该成功");
        assertTrue(sendResult, "send应该成功");
        assertTrue(callResult, "call应该成功");
        
        // 验证总共转账了三次
        assertEq(testUser.balance, initialUserBalance + transferAmount * 3, "接收方应该收到三笔转账");
    }

    /**
     * @dev 测试余额不足时的转账失败情况
     */
    function test_TransferInsufficientBalance() public {
        uint256 excessiveAmount = transferContract.getContractBalance() + 1 ether;
        
        // 验证transfer在余额不足时会失败
        vm.expectRevert("Insufficient contract balance");
        transferContract.transferEther(testUser, excessiveAmount);
        
        // 验证send在余额不足时会失败
        bool sendResult = transferContract.sendEther(testUser, excessiveAmount);
        assertFalse(sendResult, "send在余额不足时应该失败");
        
        // 验证call在余额不足时会失败
        bool callResult = transferContract.callEther(testUser, excessiveAmount, "");
        assertFalse(callResult, "call在余额不足时应该失败");
    }
}

/**
 * @title 测试用户合约
 * @dev 用于接收转账的测试合约
 */
contract TestUser {
    // 接收以太币
    receive() external payable {}
    
    // 后备函数
    fallback() external payable {}
}