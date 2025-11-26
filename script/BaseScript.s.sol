// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

abstract contract BaseScript is Script {
    address internal deployer;
    address internal user;
    string internal mnemonic;
    uint256 internal deployerPrivateKey;

    function setUp() public virtual {
        // mnemonic = vm.envString("MNEMONIC");
        // console.log('mnemonic', mnemonic);
        // (deployer, ) = deriveRememberKey(mnemonic, 0);
        // console.log("deployer: %s", deployer);

        // deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        // console.log('deployerPrivateKey', deployerPrivateKey);
        // user = vm.addr(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC);
        deployerPrivateKey = 0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a;
        // console.log("deployer: %s", user);
    }

    // 部署合约的时候记录部署合约生成address地址
    function saveContract(string memory name, address addr) public {
        string memory chainId = vm.toString(block.chainid);
        
        string memory json1 = "key";
        string memory finalJson =  vm.serializeAddress(json1, "address", addr);
        string memory fileName = string.concat("deployments/", string.concat(name, string.concat("_", string.concat(chainId, ".json"))));
        vm.writeJson(finalJson, fileName); 
        console.log("Contract address saved to %s", fileName);
    }

    modifier broadcaster() {
        // vm.startBroadcast(deployer);
        vm.startBroadcast(deployerPrivateKey);
        _;
        vm.stopBroadcast();
    }
}
