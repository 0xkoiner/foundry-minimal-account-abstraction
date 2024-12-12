# Minimal Abstract Account on Ethereum

A lightweight and modular implementation of an abstract account on Ethereum, designed for simplicity and flexibility. This project includes contracts and testing for Ethereum’s `Account Abstraction (EIP-4337)` with a focus on modularity, minimalism, and compliance with the latest standards.

## Smart Contracts

- EntryPoint.sol: The central contract implementing the entry point for account abstraction, managing user operations (UserOps) and orchestrating validation and execution.
- MinimalAccount.sol: A simple and extensible abstract account contract for Ethereum, providing basic functionality for account abstraction.
- AccountFactory.sol: Facilitates the deployment of MinimalAccount instances, ensuring streamlined and standardized account creation.
- TestToken.sol: An ERC20 token contract included for testing account interactions and transactions.

## Features

- Account Abstraction: Implements EIP-4337 for modular and gas-efficient account management.
- Minimal Design: Focused on simplicity and extensibility, making it ideal for further customization.
- Modular Architecture: Clean separation of components for ease of understanding and integration into broader systems.
- Factory Deployment: Simplifies the creation of new accounts using the AccountFactory contract.

##Testing

This project includes comprehensive tests to ensure correctness and reliability:

- EntryPoint Functionality: Verified handling of UserOps, validation logic, and execution.
- MinimalAccount Behavior: Tested basic account operations, including authentication and transaction signing.
- Factory Deployments: Confirmed the correct deployment of accounts through the AccountFactory.
- Token Interactions: Ensured smooth integration of MinimalAccount with ERC20 tokens for transactions and approvals.
- Edge Cases and Gas Optimization: Covered various scenarios, including invalid UserOps and gas efficiency under different conditions.
- Extensive Testing Framework: Used Foundry to rigorously test all contracts, ensuring robustness under edge cases.

## How It Works

1. Entry Point: UserOps are sent to the EntryPoint contract for validation and execution.
2. Account Deployment: MinimalAccount instances are deployed via the AccountFactory.
3. User Operations: EntryPoint handles UserOps, delegating execution to MinimalAccount.
4. ERC20 Integration: Interactions with ERC20 tokens are tested for compatibility and efficiency.

## Ideal For

This project is perfect for developers exploring EIP-4337 or looking to build a foundation for account abstraction on Ethereum. Its minimalistic and modular design makes it an excellent starting point for further customization and learning.

License
This project is licensed under the MIT License. See the LICENSE file for details.

