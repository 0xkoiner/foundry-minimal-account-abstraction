// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {Test} from "forge-std/Test.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {SendPackedUserOp} from "script/SendPackedUserOp.s.sol";
import {MinimalAccount} from "src/ethereum/MinimalAccount.sol";
import {DeployMinimalAccount} from "script/DeployMinimalAccount.s.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {IEntryPoint} from "@account-abstraction/contracts/interfaces/IEntryPoint.sol";
import {PackedUserOperation} from "@account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract MinimalAccountTest is Test {
    using MessageHashUtils for bytes32;

    HelperConfig helperConfig;
    MinimalAccount minimalAccount;
    SendPackedUserOp sendPackedUserOp;
    PackedUserOperation packedUserOperation;
    DeployMinimalAccount deployMinimalAccount;

    ERC20Mock public usdcMockErc20;
    uint256 public constant USDC_AMOUNT = 1000e18;
    uint256 public constant ETH_AMOUNT = 10e18;

    address public USER_A = makeAddr("USER_A");

    function setUp() public {
        deployMinimalAccount = new DeployMinimalAccount();
        (minimalAccount, helperConfig) = deployMinimalAccount.run();
        usdcMockErc20 = new ERC20Mock();
        sendPackedUserOp = new SendPackedUserOp();
    }

    function testOwnerCanExecuteCommands() public {
        assertEq(usdcMockErc20.balanceOf(address(minimalAccount)), 0);
        address dest = (address(usdcMockErc20));
        uint256 value = 0;
        bytes memory funcData = abi.encodeWithSelector(
            ERC20Mock.mint.selector,
            address(minimalAccount),
            USDC_AMOUNT
        );

        vm.startPrank(minimalAccount.owner());
        minimalAccount.execute(dest, value, funcData);
        vm.stopPrank();

        assertEq(usdcMockErc20.balanceOf(address(minimalAccount)), USDC_AMOUNT);
    }

    function testNonOwnerCannotExecuteCommands() public {
        assertEq(usdcMockErc20.balanceOf(address(minimalAccount)), 0);
        address dest = (address(usdcMockErc20));
        uint256 value = 0;
        bytes memory funcData = abi.encodeWithSelector(
            ERC20Mock.mint.selector,
            address(minimalAccount),
            USDC_AMOUNT
        );

        vm.startPrank(USER_A);
        vm.expectRevert(
            MinimalAccount.MinimalAccount__NotFromEntryPointOrOwner.selector
        );
        minimalAccount.execute(dest, value, funcData);
        vm.stopPrank();
    }

    function testRecoverSignedOp() public {
        assertEq(usdcMockErc20.balanceOf(address(minimalAccount)), 0);
        address dest = (address(usdcMockErc20));
        uint256 value = 0;
        bytes memory funcData = abi.encodeWithSelector(
            ERC20Mock.mint.selector,
            address(minimalAccount),
            USDC_AMOUNT
        );
        bytes memory executionData = abi.encodeWithSelector(
            minimalAccount.execute.selector,
            dest,
            value,
            funcData
        );

        packedUserOperation = sendPackedUserOp.generatedSignedUserOp(
            executionData,
            helperConfig.getConfig(),
            address(minimalAccount)
        );
        bytes32 userOpHash = IEntryPoint(helperConfig.getConfig().entryPoint)
            .getUserOpHash(packedUserOperation);

        address actualSigner = ECDSA.recover(
            userOpHash.toEthSignedMessageHash(),
            packedUserOperation.signature
        );

        assertEq(actualSigner, minimalAccount.owner());
    }

    function testValidationOfUserOps() public {
        assertEq(usdcMockErc20.balanceOf(address(minimalAccount)), 0);
        address dest = (address(usdcMockErc20));
        uint256 value = 0;
        bytes memory funcData = abi.encodeWithSelector(
            ERC20Mock.mint.selector,
            address(minimalAccount),
            USDC_AMOUNT
        );
        bytes memory executionData = abi.encodeWithSelector(
            minimalAccount.execute.selector,
            dest,
            value,
            funcData
        );

        packedUserOperation = sendPackedUserOp.generatedSignedUserOp(
            executionData,
            helperConfig.getConfig(),
            address(minimalAccount)
        );
        bytes32 userOpHash = IEntryPoint(helperConfig.getConfig().entryPoint)
            .getUserOpHash(packedUserOperation);

        uint256 missingAccountFunds = 1e18;

        vm.startPrank(helperConfig.getConfig().entryPoint);
        uint256 validationData = minimalAccount.validateUserOp(
            packedUserOperation,
            userOpHash,
            missingAccountFunds
        );
        vm.stopPrank();

        assertEq(validationData, 0);
    }

    function testEntryPointCanExecuteCommands() public {
        assertEq(usdcMockErc20.balanceOf(address(minimalAccount)), 0);
        address dest = (address(usdcMockErc20));
        uint256 value = 0;
        bytes memory funcData = abi.encodeWithSelector(
            ERC20Mock.mint.selector,
            address(minimalAccount),
            USDC_AMOUNT
        );
        bytes memory executionData = abi.encodeWithSelector(
            minimalAccount.execute.selector,
            dest,
            value,
            funcData
        );

        packedUserOperation = sendPackedUserOp.generatedSignedUserOp(
            executionData,
            helperConfig.getConfig(),
            address(minimalAccount)
        );

        vm.deal(address(minimalAccount.owner()), ETH_AMOUNT);
        PackedUserOperation[]
            memory packedUserOperationArray = new PackedUserOperation[](1);
        packedUserOperationArray[0] = packedUserOperation;

        vm.startPrank(USER_A);
        IEntryPoint(helperConfig.getConfig().entryPoint).handleOps(
            packedUserOperationArray,
            payable(USER_A)
        );

        vm.stopPrank();
        assertEq(usdcMockErc20.balanceOf(address(minimalAccount)), USDC_AMOUNT);
    }
}
