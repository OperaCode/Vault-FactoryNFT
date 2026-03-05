// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Vault {

    using SafeERC20 for IERC20;

    IERC20 public immutable token;

    uint256 public totalDeposits;

    mapping(address => uint256) public deposits;

    event Deposited(address indexed user, uint256 amount);

    constructor(address _token) {
        token = IERC20(_token);
    }

    function deposit(uint256 amount) external {

        require(amount > 0, "Deposit amount should not be zero");

        token.safeTransferFrom(msg.sender, address(this), amount);

        deposits[msg.sender] += amount;
        totalDeposits += amount;

        emit Deposited(msg.sender, amount);
    }
}