// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TrussetCommunityToken.sol";

contract StakingContract {
    TrussetCommunityToken public token;
    uint256 public annualInterestRate = 2;
    mapping(address => uint256) public stakedAmount;
    mapping(address => uint256) public stakingStartTime;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount, uint256 reward);
    event RewardsMinted(address indexed user, uint256 reward);

    constructor(TrussetCommunityToken _token) {
        token = _token;
    }

    function stake(uint256 _amount) public {
        require(_amount > 0, "Cannot stake 0 tokens");
        require(token.transferFrom(msg.sender, address(this), _amount), "Transfer failed");
        stakedAmount[msg.sender] += _amount;
        stakingStartTime[msg.sender] = block.timestamp;
        emit Staked(msg.sender, _amount);
    }

    function unstake() public {
        require(stakedAmount[msg.sender] > 0, "No tokens staked");
        uint256 stakedTime = block.timestamp - stakingStartTime[msg.sender];
        uint256 reward = calculateReward(stakedAmount[msg.sender], stakedTime);
        uint256 total = stakedAmount[msg.sender] + reward;
        stakedAmount[msg.sender] = 0;
        token.mint(msg.sender, reward);
        require(token.transfer(msg.sender, total), "Transfer failed");
        emit Unstaked(msg.sender, total, reward);
        emit RewardsMinted(msg.sender, reward);
    }

    function calculateReward(uint256 _amount, uint256 _stakedTime) public view returns (uint256) {
        uint256 reward = (_amount * annualInterestRate * _stakedTime) / (365 days * 100);
        return reward;
    }
}
