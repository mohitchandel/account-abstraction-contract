// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IDelegation {
    /**
     * @notice Struct to store user's delegation settings
     * @param user Address of the user
     * @param isAllowed Boolean to allow or disallow delegation
     * @param maxLimit Maximum amount that can be delegated
     * @param limitLeft Amount left to be delegated
     */
    struct DelegationSettings {
        address user;
        bool isAllowed;
        uint256 maxLimit;
        uint256 limitLeft;
    }

    /**
     * @notice Function to allow users to set delegation preferences
     * @param isAllowed Boolean to allow or disallow delegation
     * @param maxLimit Maximum amount that can be delegated
     * @dev This function will be called by the user.
     */
    function setDelegation(bool isAllowed, uint256 maxLimit) external;

    /**
     * @notice Function to allow users to withdraw delegation
     * @dev This function will be called by the user.
     */
    function withdrawDelegation() external;

    /**
     * @notice Function to allow users to increase delegation limit
     * @param _amount Amount to increase the delegation limit
     * @dev This function will be called by the user.
     */
    function increaseDelegationLimit(uint256 _amount) external;

    /**
     * @notice Function to allow users to decrease delegation limit
     * @param _amount Amount to decrease the delegation limit
     * @dev This function will be called by the user.
     */
    function decreaseDelegationLimit(uint256 _amount) external;

    /**
     * @notice Event emitted when user sets delegation
     * @param _isDelegated Boolean to allow or disallow delegation
     */
    event SetUserDelegation(bool _isDelegated, address indexed _user);

    /**
     * @notice Event emitted when user increases delegation limit
     * @param _user Address of the user
     */
    event IncreasedDelegationLimit(address indexed _user, uint256 _amount);

    /**
     * @notice Event emitted when user decreases delegation limit
     * @param _user Address of the user
     */
    event WithdrawDelegation(address indexed _user);

    /**
     * @notice Event emitted when user decreases delegation limit
     * @param _user Address of the user
     */
    event DecreasedDelegationLimit(address indexed _user, uint256 _amount);
}
