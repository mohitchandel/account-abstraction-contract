# AccountDelegation Smart Contract Documentation

## Problem Statement

The AccountDelegation contract aims to solve the problem of allowing a Vault Manager to perform token swaps on behalf of a user without the need for the user to sign each transaction. The contract introduces the concept of account abstraction to enable delegation of token swap permissions to the Vault Manager. Additionally, the contract allows users to set a maximum limit for the Vault Manager to trade on their behalf, providing more control over their funds.

## Description

The AccountDelegation contract is an Ethereum smart contract written in Solidity that facilitates delegation of token swap permissions between a user and a Vault Manager. Users can set delegation preferences, allowing the Vault Manager to perform token swaps on their behalf within specified limits.

The contract is designed to work with the EVM blockchain, making use of the Uniswap v3-periphery library for token swapping functionality.

## Functionalities

The AccountDelegation contract provides the following functionalities:

### 1. Set Delegation

Function Signature: `setDelegation(bool isAllowed, uint256 maxLimit)`

- Allows users to set delegation preferences for the Vault Manager.
- Users can enable or disable delegation by setting the `isAllowed` flag to `true` or `false`, respectively.
- Users can set the maximum limit (`maxLimit`) for the Vault Manager to trade on their behalf.
- Once delegation is set, the Vault Manager can perform token swaps on behalf of the user within the specified `maxLimit`.

### 2. Perform Token Swap

Function Signature: `performTokenSwap(address user, address tokenIn, address tokenOut, uint256 amountIn)`

- Allows the Vault Manager to perform token swaps on behalf of the user.
- The user must have enabled delegation for the Vault Manager (`isAllowed = true`) to perform the swap.
- The amount to be swapped (`amountIn`) must not exceed the user's set `maxLimit`.
- The token swap uses Uniswap v3-periphery's `ISwapRouter` contract to execute the swap.

### 3. Withdraw Delegation

Function Signature: `withdrawDelegation()`

- Allows the user to withdraw delegation preferences.
- Once withdrawn, the Vault Manager will no longer be able to perform token swaps on behalf of the user.

### 4. Increase Delegation Limit

Function Signature: `increaseDelegationLimit(uint256 amount)`

- Allows the user to increase the maximum limit for the Vault Manager to trade on their behalf.
- The user must have enabled delegation for the Vault Manager (`isAllowed = true`) to increase the limit.

### 5. Decrease Delegation Limit

Function Signature: `decreaseDelegationLimit(uint256 amount)`

- Allows the user to decrease the maximum limit for the Vault Manager to trade on their behalf.
- The user must have enabled delegation for the Vault Manager (`isAllowed = true`) to decrease the limit.
- The decrease in limit must not exceed the difference between the user's set `maxLimit` and the `limitLeft`.

## Implementation Details

The AccountDelegation contract uses the Uniswap v3-periphery library (`@uniswap/v3-periphery`) for token swapping functionality. The contract deploys with the address of the Vault Manager as the contract creator (`msg.sender`).

The contract stores user delegation settings in a mapping (`userDelegation`) where each user's Ethereum address is associated with a `DelegationSettings` struct that holds their delegation preferences. The struct contains the user's address, delegation status (`isAllowed`), maximum limit for the Vault Manager to trade (`maxLimit`), and the remaining limit available for trading (`limitLeft`).

The contract emits events for important actions, such as setting delegation preferences, increasing/decreasing the trading limit, and withdrawing delegation.

## Example Usage

### Deployment

1. Deploy the `AccountDelegation` contract on the any network with the Uniswap v3-periphery [`ISwapRouter`](https://docs.uniswap.org/contracts/v3/reference/deployments) address.

### User Actions

1. A user can call the `setDelegation` function to enable delegation and set their maximum trading limit for the Vault Manager.
2. The user can call `performTokenSwap` to allow the Vault Manager to perform token swaps on their behalf within the set limit.
3. If needed, the user can increase or decrease the delegation limit using `increaseDelegationLimit` and `decreaseDelegationLimit` functions, respectively.
4. The user can withdraw delegation by calling the `withdrawDelegation` function.

## Considerations

- Before deploying and using the contract, ensure that the contract deployer is the designated Vault Manager, as the deployer's address becomes the manager's address (`msg.sender`).
- Carefully consider the token swapping logic and the potential risks associated with allowing the Vault Manager to trade on behalf of users.
