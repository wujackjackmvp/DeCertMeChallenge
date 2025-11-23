// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/**
 * @title 转账示例合约
 * @dev 本合约演示Solidity中三种转账方式：transfer、send和call.value的区别
 */
contract TransferExamples {
    // 事件声明
    event TransferSent(address indexed from, address indexed to, uint256 amount);
    event SendSent(address indexed from, address indexed to, uint256 amount, bool success);
    event CallSent(address indexed from, address indexed to, uint256 amount, bool success, bytes data);
    event Received(address indexed sender, uint256 amount);

    // ========== 余额查询功能 ==========
    /**
     * @dev 获取合约当前余额
     * @return 合约中的以太币余额（以wei为单位）
     */
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @dev 获取指定地址的余额
     * @param addr 要查询的地址
     * @return 地址中的以太币余额（以wei为单位）
     */
    function getAddressBalance(address addr) public view returns (uint256) {
        return addr.balance;
    }

    // ========== transfer 方式转账 ==========
    /**
     * @dev 使用transfer方式转账
     * @param to 接收地址
     * @param amount 转账金额（以wei为单位）
     * @notice transfer会在失败时自动回滚交易，gas限制为2300
     */
    function transferEther(address payable to, uint256 amount) public payable {
        // 检查转账金额不超过合约余额
        require(amount <= address(this).balance, "Insufficient contract balance");
        
        // 使用transfer方式转账
        to.transfer(amount);
        
        // 触发事件
        emit TransferSent(msg.sender, to, amount);
    }

    // ========== send 方式转账 ==========
    /**
     * @dev 使用send方式转账
     * @param to 接收地址
     * @param amount 转账金额（以wei为单位）
     * @return 转账是否成功
     * @notice send在失败时不会自动回滚交易，返回布尔值表示成功或失败，gas限制为2300
     */
    function sendEther(address payable to, uint256 amount) public payable returns (bool) {
        // 检查转账金额不超过合约余额
        require(amount <= address(this).balance, "Insufficient contract balance");
        
        // 使用send方式转账
        bool success = to.send(amount);
        
        // 触发事件
        emit SendSent(msg.sender, to, amount, success);
        
        return success;
    }

    // ========== call.value 方式转账 ==========
    /**
     * @dev 使用call.value方式转账
     * @param to 接收地址
     * @param amount 转账金额（以wei为单位）
     * @param data 可选的调用数据
     * @return 转账是否成功
     * @notice call.value是最灵活的转账方式，可以设置gas限制，失败时不会自动回滚
     */
    function callEther(address payable to, uint256 amount, bytes memory data) public payable returns (bool) {
        // 检查转账金额不超过合约余额
        require(amount <= address(this).balance, "Insufficient contract balance");
        
        // 使用call.value方式转账，这里设置gas限制为100000
        (bool success, bytes memory returnData) = to.call{value: amount, gas: 100000}(data);
        
        // 触发事件
        emit CallSent(msg.sender, to, amount, success, returnData);
        
        return success;
    }

    /**
     * @dev 接收以太币的回退函数
     * @notice 允许合约接收以太币
     */
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    /**
     * @dev 后备函数
     * @notice 当没有匹配的函数被调用或接收以太币但没有receive函数时触发
     */
    fallback() external payable {
        emit Received(msg.sender, msg.value);
    }

    // ========== 便捷函数 ==========
    /**
     * @dev 向合约存款
     * @notice 允许用户向合约存入以太币
     */
    function deposit() public payable {
        emit Received(msg.sender, msg.value);
    }

    /**
     * @dev 演示三种转账方式的对比
     * @param to 接收地址
     * @param amount 转账金额（以wei为单位）
     * @return transferResult transfer方式的结果
     * @return sendResult send方式的结果
     * @return callResult call方式的结果
     */
    function compareTransferMethods(address payable to, uint256 amount) public payable 
        returns (bool transferResult, bool sendResult, bool callResult) 
    {
        require(amount <= address(this).balance / 3, "Insufficient contract balance for all transfers");
        
        // 使用三种方式分别转账
        // 注意：如果transfer失败会直接回滚整个交易，所以将它放在最后
        
        // 1. send方式
        sendResult = sendEther(to, amount);
        
        // 2. call.value方式
        callResult = callEther(to, amount, "");
        
        // 3. transfer方式（如果失败会回滚）
        transferEther(to, amount);
        transferResult = true; // 如果执行到这里，说明transfer成功
        
        return (transferResult, sendResult, callResult);
    }
}