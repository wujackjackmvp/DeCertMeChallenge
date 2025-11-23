// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/**
 * @title 值类型和引用类型演示合约
 * @dev 本合约演示Solidity中的值类型和引用类型的区别和使用方法
 */
contract ValueReferenceTypes {
    // ========== 值类型示例 ==========
    // 值类型：直接存储数据值，赋值时会创建副本
    uint256 public valueTypeNumber = 100; // 无符号整数
    bool public valueTypeBool = true;     // 布尔值
    address public valueTypeAddress = 0x1234567890123456789012345678901234567890; // 地址
    bytes32 public valueTypeBytes = 0xabcdef0000000000000000000000000000000000000000000000000000000000; // 固定大小字节数组

    // ========== 引用类型示例 ==========
    // 引用类型：存储数据的引用（位置），赋值时可能会共享引用
    uint256[] public referenceTypeArray = [1, 2, 3, 4, 5]; // 动态数组
    mapping(uint256 => string) public referenceTypeMapping; // 映射
    
    // 结构体（引用类型）
    struct Person {
        string name;
        uint256 age;
        bool isActive;
    }
    
    Person public referenceTypeStruct;

    // ========== 值类型演示函数 ==========
    /**
     * @dev 演示值类型的行为 - 复制值而不是引用
     * @param inputNumber 输入的数字
     * @return 函数内修改后的局部变量值
     */
    function demonstrateValueType(uint256 inputNumber) public returns (uint256) {
        // 创建局部变量，复制全局变量的值
        uint256 localVar = valueTypeNumber;
        
        // 修改局部变量不会影响全局变量
        localVar = inputNumber;
        
        return localVar;
    }

    // ========== 引用类型演示函数 ==========
    /**
     * @dev 演示数组（引用类型）的行为 - 在函数内修改会影响存储中的状态
     * @param index 要修改的数组索引
     * @param newValue 新值
     */
    function demonstrateReferenceTypeArray(uint256 index, uint256 newValue) public {
        // 直接修改存储中的数组，会永久改变状态
        if (index < referenceTypeArray.length) {
            referenceTypeArray[index] = newValue;
        }
    }

    /**
     * @dev 演示通过memory修饰符使用引用类型
     * @return 新创建的数组
     */
    function demonstrateMemoryReferenceType() public pure returns (uint256[] memory) {
        // 在内存中创建一个新数组，不会影响存储
        uint256[] memory memoryArray = new uint256[](3);
        memoryArray[0] = 10;
        memoryArray[1] = 20;
        memoryArray[2] = 30;
        
        return memoryArray; // 返回内存数组的副本
    }

    // ========== 结构体操作演示 ==========
    /**
     * @dev 设置结构体数据
     * @param name 姓名
     * @param age 年龄
     * @param isActive 是否激活
     */
    function setStructData(string calldata name, uint256 age, bool isActive) public {
        referenceTypeStruct = Person(name, age, isActive);
    }

    /**
     * @dev 修改结构体的部分字段
     * @param age 新年龄
     */
    function updateStructAge(uint256 age) public {
        referenceTypeStruct.age = age;
    }

    // ========== 映射操作演示 ==========
    /**
     * @dev 向映射中添加数据
     * @param key 键
     * @param value 值
     */
    function addToMapping(uint256 key, string calldata value) public {
        referenceTypeMapping[key] = value;
    }

    // ========== 混合演示函数 ==========
    /**
     * @dev 同时演示值类型和引用类型的不同行为
     * @param newValueTypeValue 新的值类型值
     * @param arrayIndex 要修改的数组索引
     * @param newArrayValue 新的数组值
     */
    function demonstrateBothTypes(uint256 newValueTypeValue, uint256 arrayIndex, uint256 newArrayValue) public {
        // 修改值类型 - 直接赋值
        valueTypeNumber = newValueTypeValue;
        
        // 修改引用类型中的数组
        if (arrayIndex < referenceTypeArray.length) {
            referenceTypeArray[arrayIndex] = newArrayValue;
        }
    }
}