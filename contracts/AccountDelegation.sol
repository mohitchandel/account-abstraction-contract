// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "./Interfaces/IDelegation.sol";

contract AccountDelegation is IDelegation {
    address public manager; // Address of the Vault Manager

    ISwapRouter public swapRouter;
    uint24 public constant poolFee = 3000;

    // Mapping to store user's delegation settings
    mapping(address => DelegationSettings) public userDelegation;
    DelegationSettings public defaultSettings;

    constructor(ISwapRouter _swapRouter) {
        // Set the contract deployer as the Vault Manager
        manager = msg.sender;
        swapRouter = _swapRouter;
    }

    // Function to allow users to set delegation preferences
    function setDelegation(bool isAllowed, uint256 maxLimit) external override {
        require(
            userDelegation[msg.sender].user == address(0),
            "AccountDelegation::setDelegation: Already delegated"
        );
        require(
            maxLimit > 0,
            "AccountDelegation::setDelegation: Max limit cannot be 0"
        );
        require(
            msg.sender != manager,
            "AccountDelegation::setDelegation: Vault Manager can not delegate"
        );
        userDelegation[msg.sender] = DelegationSettings(
            msg.sender,
            isAllowed,
            maxLimit,
            maxLimit
        );
        emit SetUserDelegation(true, msg.sender);
    }

    /**
     * @notice Function to perform token swap
     * @param user Address of the user
     * @param _tokenIn Address of the token to swap
     * @param _tokenOut Address of the token to receive
     * @param amountIn Amount of token to swap
     * @return amountOut Amount of token received
     * @dev This function will be called by the Vault Manager.
     */
    function performTokenSwap(
        address user,
        address _tokenIn,
        address _tokenOut,
        uint256 amountIn
    ) external returns (uint256 amountOut) {
        require(
            msg.sender == manager,
            "AccountDelegation::performTokenSwap: Only Vault Manager can call this"
        );
        // Check if the user has delegated the Vault Manager
        require(
            userDelegation[user].isAllowed,
            "AccountDelegation::performTokenSwap: User has not delegated"
        );

        // Check if the amount to trade is within the user's max limit
        require(
            amountIn <= userDelegation[user].limitLeft,
            "AccountDelegation::performTokenSwap: Amount exceeds limit left"
        );

        TransferHelper.safeTransferFrom(
            _tokenIn,
            msg.sender,
            address(this),
            amountIn
        );

        // Approve the router to spend token.
        TransferHelper.safeApprove(_tokenIn, address(swapRouter), amountIn);

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: _tokenIn,
                tokenOut: _tokenOut,
                fee: poolFee,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        userDelegation[user].limitLeft =
            userDelegation[user].maxLimit -
            amountIn;
        amountOut = swapRouter.exactInputSingle(params);
    }

    // Function to withdraw delegation
    function withdrawDelegation() external override {
        require(
            msg.sender != manager,
            "AccountDelegation::withdrawDelegation: Only user can perform this"
        );
        require(
            userDelegation[msg.sender].isAllowed,
            "AccountDelegation::withdrawDelegation: User must delegate to use this"
        );
        userDelegation[msg.sender] = defaultSettings;
        emit WithdrawDelegation(msg.sender);
    }

    // Function to increase the delegation limit
    function increaseDelegationLimit(uint256 _amount) external override {
        require(
            msg.sender != manager,
            "AccountDelegation::increaseDelegationLimit: Only user can perform this"
        );
        require(
            userDelegation[msg.sender].isAllowed,
            "AccountDelegation::increaseDelegationLimit: User must delegate to use this"
        );
        userDelegation[msg.sender].maxLimit =
            userDelegation[msg.sender].maxLimit +
            _amount;
        emit IncreasedDelegationLimit(msg.sender, _amount);
    }

    // Function to decrease the delegation limit
    function decreaseDelegationLimit(uint256 _amount) external override {
        require(
            msg.sender != manager,
            "AccountDelegation::decreaseDelegationLimit: Only user can perform this"
        );
        require(
            userDelegation[msg.sender].isAllowed,
            "AccountDelegation::decreaseDelegationLimit: User must delegate to use this"
        );
        require(
            _amount <= userDelegation[msg.sender].limitLeft,
            "AccountDelegation::decreaseDelegationLimit: Invalid amount, this can't be reduced"
        );
        userDelegation[msg.sender].maxLimit =
            userDelegation[msg.sender].maxLimit -
            _amount;
        userDelegation[msg.sender].limitLeft =
            userDelegation[msg.sender].limitLeft -
            _amount;
        emit DecreasedDelegationLimit(msg.sender, _amount);
    }
}
