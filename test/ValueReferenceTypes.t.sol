// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {ValueReferenceTypes} from "../src/ValueReferenceTypes.sol";

/**
 * @title 值类型和引用类型测试合约
 * @dev 测试ValueReferenceTypes合约中值类型和引用类型的行为差异
 */
contract ValueReferenceTypesTest is Test {
    ValueReferenceTypes public valueRefContract;

    /**
     * @dev 测试设置函数，在每个测试前运行
     */
    function setUp() public {
        valueRefContract = new ValueReferenceTypes();
    }

    /**
     * @dev 测试值类型的行为 - 验证函数内修改不影响原始值
     */
    function test_ValueTypeBehavior() public {
        // 记录初始值
        uint256 initialValue = valueRefContract.valueTypeNumber();
        
        // 调用函数修改局部值
        uint256 returnedValue = valueRefContract.demonstrateValueType(500);
        
        // 验证返回值是新值
        assertEq(returnedValue, 500, "返回值应该是500");
        
        // 验证全局变量未被修改（仍然是原值）
        assertEq(valueRefContract.valueTypeNumber(), initialValue, "全局值类型变量应该保持不变");
    }

    /**
     * @dev 测试引用类型数组的行为 - 验证修改会影响存储状态
     */
    function test_ReferenceTypeArrayBehavior() public {
        // 记录数组的初始值
        uint256 initialValue = valueRefContract.referenceTypeArray(0);
        
        // 修改数组元素
        uint256 newValue = 1000;
        valueRefContract.demonstrateReferenceTypeArray(0, newValue);
        
        // 验证数组元素已被修改
        assertEq(valueRefContract.referenceTypeArray(0), newValue, "数组元素应该被修改");
        assertNotEq(valueRefContract.referenceTypeArray(0), initialValue, "数组元素应该不同于初始值");
    }

    /**
     * @dev 测试memory引用类型的行为
     */
    function test_MemoryReferenceType() public {
        // 调用返回memory数组的函数
        uint256[] memory resultArray = valueRefContract.demonstrateMemoryReferenceType();
        
        // 验证返回的数组内容正确
        assertEq(resultArray.length, 3, "返回的数组长度应该是3");
        assertEq(resultArray[0], 10, "第一个元素应该是10");
        assertEq(resultArray[1], 20, "第二个元素应该是20");
        assertEq(resultArray[2], 30, "第三个元素应该是30");
    }

    /**
     * @dev 测试结构体的设置和更新功能
     */
    function test_StructOperations() public {
        // 设置结构体数据
        string memory name = "Alice";
        uint256 age = 30;
        bool isActive = true;
        valueRefContract.setStructData(name, age, isActive);
        
        // 验证结构体数据设置正确
        (string memory savedName, uint256 savedAge, bool savedActive) = valueRefContract.referenceTypeStruct();
        assertEq(savedName, name, "姓名应该正确设置");
        assertEq(savedAge, age, "年龄应该正确设置");
        assertEq(savedActive, isActive, "激活状态应该正确设置");
        
        // 更新结构体的部分字段
        uint256 newAge = 31;
        valueRefContract.updateStructAge(newAge);
        
        // 验证年龄已更新
        (savedName, savedAge, savedActive) = valueRefContract.referenceTypeStruct();
        assertEq(savedAge, newAge, "年龄应该被更新");
        // 验证其他字段保持不变
        assertEq(savedName, name, "姓名应该保持不变");
        assertEq(savedActive, isActive, "激活状态应该保持不变");
    }

    /**
     * @dev 测试映射的添加和查询功能
     */
    function test_MappingOperations() public {
        // 向映射中添加数据
        uint256 key = 1;
        string memory value = "Test Value";
        valueRefContract.addToMapping(key, value);
        
        // 验证映射数据添加正确
        assertEq(valueRefContract.referenceTypeMapping(key), value, "映射中的值应该正确");
    }

    /**
     * @dev 测试混合类型操作函数
     */
    function test_MixedTypesOperation() public {
        // 准备测试数据
        uint256 newValueTypeValue = 200;
        uint256 arrayIndex = 1;
        uint256 newArrayValue = 2000;
        
        // 调用混合操作函数
        valueRefContract.demonstrateBothTypes(newValueTypeValue, arrayIndex, newArrayValue);
        
        // 验证值类型变量已更新
        assertEq(valueRefContract.valueTypeNumber(), newValueTypeValue, "值类型变量应该被更新");
        
        // 验证数组元素已更新
        assertEq(valueRefContract.referenceTypeArray(arrayIndex), newArrayValue, "数组元素应该被更新");
    }
}