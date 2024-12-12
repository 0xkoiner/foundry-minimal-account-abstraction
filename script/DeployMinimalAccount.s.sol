// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {MinimalAccount} from "src/ethereum/MinimalAccount.sol";

contract DeployMinimalAccount is Script {
    MinimalAccount minimalAccount;
    HelperConfig helperConfig;
    HelperConfig.NetworkConfig config;

    function run() external returns (MinimalAccount, HelperConfig) {
        helperConfig = new HelperConfig();
        config = helperConfig.getConfig();
        vm.createSelectFork("mainnet");
        vm.startBroadcast();
        minimalAccount = new MinimalAccount(config.entryPoint);
        minimalAccount.transferOwnership(config.account);
        vm.stopBroadcast();
        return (minimalAccount, helperConfig);
    }
}
