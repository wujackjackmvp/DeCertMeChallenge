// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {TransferExamples} from "../src/TransferExamples.sol";

/**
     * @title Transfer Examples Test Contract
     * @dev Tests the transfer functionality in TransferExamples contract
     */
contract TransferExamplesTest is Test {
    TransferExamples public transferContract;
    address payable public testUser;
    uint256 public initialBalance = 1 ether;

    /**
     * @dev Test setup function, runs before each test
     */
    function setUp() public {
        // 创建转账合约
        transferContract = new TransferExamples();
        
        // 创建测试用户地址
        testUser = payable(address(new TestUser()));
    }

    /**
     * @dev Tests balance query functionality
     */
    function test_GetBalance() public {
        // 验证合约初始余额
        assertEq(transferContract.getContractBalance(), initialBalance, "Contract initial balance should be correct");
        
        // 验证地址余额查询
        assertEq(transferContract.getAddressBalance(address(transferContract)), initialBalance, "Address balance query should be correct");
    }

    /**
     * @dev Tests transfer functionality
     */
    function test_TransferEther() public {
        uint256 transferAmount = 0.1 ether;
        uint256 initialUserBalance = testUser.balance;
        uint256 initialContractBalance = transferContract.getContractBalance();
        
        // 执行转账
        transferContract.transferEther(testUser, transferAmount);
        
        // 验证转账结果
        assertEq(testUser.balance, initialUserBalance + transferAmount, "Recipient balance should increase");
        assertEq(transferContract.getContractBalance(), initialContractBalance - transferAmount, "Contract balance should decrease");
    }

    /**
     * @dev Tests send functionality
     */
    function test_SendEther() public {
        uint256 sendAmount = 0.2 ether;
        uint256 initialUserBalance = testUser.balance;
        uint256 initialContractBalance = transferContract.getContractBalance();
        
        // 执行转账
        bool success = transferContract.sendEther(testUser, sendAmount);
        
        // 验证转账成功
        assertTrue(success, "Send transfer should succeed");
        assertEq(testUser.balance, initialUserBalance + sendAmount, "Recipient balance should increase");
        assertEq(transferContract.getContractBalance(), initialContractBalance - sendAmount, "Contract balance should decrease");
    }

    /**
     * @dev Tests call.value functionality
     */
    function test_CallEther() public {
        uint256 callAmount = 0.3 ether;
        uint256 initialUserBalance = testUser.balance;
        uint256 initialContractBalance = transferContract.getContractBalance();
        bytes memory emptyData = "";
        
        // 执行转账
        bool success = transferContract.callEther(testUser, callAmount, emptyData);
        
        // 验证转账成功
        assertTrue(success, "Call transfer should succeed");
        assertEq(testUser.balance, initialUserBalance + callAmount, "Recipient balance should increase");
        assertEq(transferContract.getContractBalance(), initialContractBalance - callAmount, "Contract balance should decrease");
    }

    /**
     * @dev Tests deposit functionality
     */
    function test_Deposit() public {
        uint256 depositAmount = 0.5 ether;
        uint256 initialContractBalance = transferContract.getContractBalance();
        
        // 向合约存款
        (bool success, ) = address(transferContract).call{value: depositAmount}(abi.encodeWithSignature("deposit()"));
        assertTrue(success, "Deposit should succeed");
        
        // 验证存款结果
        assertEq(transferContract.getContractBalance(), initialContractBalance + depositAmount, "Contract balance should increase");
    }

    /**
     * @dev Tests comparing three transfer methods
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
            assertTrue(success, "Supplementary deposit should succeed");
        }
        
        // 调用比较函数
        (bool transferResult, bool sendResult, bool callResult) = transferContract.compareTransferMethods(testUser, transferAmount);
        
        // 验证所有转账方式都成功
        assertTrue(transferResult, "Transfer should succeed");
        assertTrue(sendResult, "Send should succeed");
        assertTrue(callResult, "Call should succeed");
        
        // 验证总共转账了三次
        assertEq(testUser.balance, initialUserBalance + transferAmount * 3, "Recipient should receive three transfers");
    }

    /**
     * @dev Tests transfer failure with insufficient balance
     */
    function test_TransferInsufficientBalance() public {
        uint256 excessiveAmount = transferContract.getContractBalance() + 1 ether;
        
        // 验证transfer在余额不足时会失败
        vm.expectRevert("Insufficient contract balance");
        transferContract.transferEther(testUser, excessiveAmount);
        
        // 验证send在余额不足时会失败
        bool sendResult = transferContract.sendEther(testUser, excessiveAmount);
        assertFalse(sendResult, "Send should fail with insufficient balance");
        
        // 验证call在余额不足时会失败
        bool callResult = transferContract.callEther(testUser, excessiveAmount, "");
        assertFalse(callResult, "Call should fail with insufficient balance");
    }
}

/**
 * @title Test User Contract
 * @dev Test contract for receiving transfers
 */
contract TestUser {
    // 接收以太币
    receive() external payable {}
    
    // 后备函数
    fallback() external payable {}
}