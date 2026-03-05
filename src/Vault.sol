// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;



import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Vault {

    IERC20 public immutable token;

    uint256 public totalDeposits;

    mapping(address => uint256) public deposits;

    constructor(address _token) {
        token = IERC20(_token);
    }

    function deposit(uint256 amount) external {

        require(amount > 0, "Deposit amount should not be zero");

        token.transferFrom(msg.sender, address(this), amount);

        deposits[msg.sender] += amount;
        totalDeposits += amount;
    }
}