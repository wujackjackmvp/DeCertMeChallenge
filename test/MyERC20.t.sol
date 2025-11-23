// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/MyERC20.sol";

// 测试用的接收合约，实现ITokenReceiver接口
contract TestTokenReceiver is ITokenReceiver {
    address public lastFrom;
    address public lastTo;
    uint256 public lastAmount;
    bytes public lastData;
    bool public callbackExecuted = false;
    
    function tokensReceived(address from, address to, uint256 amount, bytes calldata data) external override {
        lastFrom = from;
        lastTo = to;
        lastAmount = amount;
        lastData = data;
        callbackExecuted = true;
    }
    
    // 重置状态，用于多次测试
    function reset() external {
        lastFrom = address(0);
        lastTo = address(0);
        lastAmount = 0;
        delete lastData;
        callbackExecuted = false;
    }
}

// 不实现ITokenReceiver接口的合约
contract NonReceiverContract {
    // 故意不实现tokensReceived函数
}

contract MyERC20Test is Test {
    MyERC20 public token;
    TestTokenReceiver public receiver;
    NonReceiverContract public nonReceiver;
    
    address public deployer = address(0x1111);
    address public user1 = address(0x2222);
    address public user2 = address(0x3333);
    
    uint256 public initialSupply = 1000000 * 10 ** 18;
    uint256 public transferAmount = 100 * 10 ** 18;
    
    function setUp() public {
        // 设置部署者地址
        vm.startPrank(deployer);
        
        // 部署合约
        token = new MyERC20("MyToken", "MTK");
        receiver = new TestTokenReceiver();
        nonReceiver = new NonReceiverContract();
        
        vm.stopPrank();
    }
    
    // 测试代币的基本信息
    function testTokenMetadata() public {
        assertEq(token.name(), "MyToken");
        assertEq(token.symbol(), "MTK");
        assertEq(token.decimals(), 18);
    }
    
    // 测试初始供应量
    function testInitialSupply() public {
        assertEq(token.totalSupply(), initialSupply);
        assertEq(token.balanceOf(deployer), initialSupply);
    }
    
    // 测试标准转账功能
    function testTransfer() public {
        // 部署者向user1转账
        vm.startPrank(deployer);
        bool success = token.transfer(user1, transferAmount);
        vm.stopPrank();
        
        assertTrue(success);
        assertEq(token.balanceOf(deployer), initialSupply - transferAmount);
        assertEq(token.balanceOf(user1), transferAmount);
    }
    
    // 测试转账失败的情况（余额不足）
    function testTransferInsufficientBalance() public {
        // user1尝试转账，但他没有代币
        vm.startPrank(user1);
        vm.expectRevert();
        token.transfer(user2, transferAmount);
        vm.stopPrank();
    }
    
    // 测试transferWithCallback向普通地址转账
    function testTransferWithCallbackToEOA() public {
        bytes memory testData = abi.encodePacked("test-data");
        
        vm.startPrank(deployer);
        bool success = token.transferWithCallback(user1, transferAmount, testData);
        vm.stopPrank();
        
        assertTrue(success);
        assertEq(token.balanceOf(deployer), initialSupply - transferAmount);
        assertEq(token.balanceOf(user1), transferAmount);
    }
    
    // 测试transferWithCallback向实现ITokenReceiver接口的合约转账
    function testTransferWithCallbackToContract() public {
        bytes memory testData = abi.encodePacked("contract-data");
        
        vm.startPrank(deployer);
        bool success = token.transferWithCallback(address(receiver), transferAmount, testData);
        vm.stopPrank();
        
        assertTrue(success);
        assertEq(token.balanceOf(deployer), initialSupply - transferAmount);
        assertEq(token.balanceOf(address(receiver)), transferAmount);
        
        // 验证回调函数被正确执行
        assertTrue(receiver.callbackExecuted());
        assertEq(receiver.lastFrom(), deployer);
        assertEq(receiver.lastTo(), address(receiver));
        assertEq(receiver.lastAmount(), transferAmount);
        assertEq(receiver.lastData(), testData);
    }
    
    // 测试transferWithCallback向未实现ITokenReceiver接口的合约转账（应该失败）
    function testTransferWithCallbackToNonReceiverContract() public {
        bytes memory testData = abi.encodePacked("non-receiver-data");
        
        vm.startPrank(deployer);
        vm.expectRevert();
        token.transferWithCallback(address(nonReceiver), transferAmount, testData);
        vm.stopPrank();
        
        // 确保余额没有变化
        assertEq(token.balanceOf(deployer), initialSupply);
        assertEq(token.balanceOf(address(nonReceiver)), 0);
    }
    
    // 测试授权和转账功能
    function testApproveAndTransferFrom() public {
        vm.startPrank(deployer);
        // 授权user1可以转移deployer的代币
        bool approveSuccess = token.approve(user1, transferAmount * 2);
        vm.stopPrank();
        
        assertTrue(approveSuccess);
        assertEq(token.allowance(deployer, user1), transferAmount * 2);
        
        // user1从deployer转移代币到user2
        vm.startPrank(user1);
        bool transferFromSuccess = token.transferFrom(deployer, user2, transferAmount);
        vm.stopPrank();
        
        assertTrue(transferFromSuccess);
        assertEq(token.balanceOf(deployer), initialSupply - transferAmount);
        assertEq(token.balanceOf(user2), transferAmount);
        assertEq(token.allowance(deployer, user1), transferAmount); // 剩余授权
    }
}