// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Stakeable {
    uint256 internal rewards_per_hour = 1000;

    constructor() {
        stakeholders.push();
    }

    struct Stake {
        address user;
        uint256 tier;
        uint256 amount;
        uint256 since;
    }

    struct Stakeholder {
        address user;
        Stake[] address_stakes;
    }

    Stakeholder[] internal stakeholders;
    mapping(address => uint256) internal stakes;
    event Staked(address indexed user, uint256 tier, uint256 amount, uint256 index, uint256 timestamp);

    function _addStakeholder(address staker) internal returns (uint256) {
        stakeholders.push();
        uint256 index = stakeholders.length - 1;
        stakeholders[index].user = staker;
        stakes[staker] = index;
        return index;
    }

    function _stake(uint256 _tier, uint256 _amount) internal {
        require(_amount > 0, "Cannot stake nothing");

        uint256 index = stakes[msg.sender];
        uint256 timestamp = block.timestamp;
        if (index == 0) {
            index = _addStakeholder(msg.sender);
        }

        stakeholders[index].address_stakes.push(Stake(msg.sender, _tier, _amount, timestamp));
        emit Staked(msg.sender, _tier, _amount, index, timestamp);
    }

    function calculateStakeReward(Stake memory _current_stake) internal view returns(uint256) {
        return (((block.timestamp - _current_stake.since) / 1 hours) * _current_stake.amount) / rewards_per_hour;
    }

    function _withdrawStake(uint256 _tier, uint256 _amount, uint256 _index) internal returns(uint256) {
        uint256 usr_idx = stakes[msg.sender];
        Stake memory current_stake = stakeholders[usr_idx].address_stakes[_index];
        require(current_stake.amount >= _amount, "Staking: cannot withdraw more than you have staked");
        uint256 reward = calculateStakeReward(current_stake);
        current_stake.amount = current_stake.amount - amount;
        if (current_stake.amount == 0) {
            delete stakeholders[usr_idx].address_stakes[_index];
        } else {
            stakeholders[usr_idx].address_stakes[_index].amount = current_stake.amount;
            stakeholders[usr_idx].address_stakes[_index].since = block.timestamp;
        }
        return _amount + reward;
    }
}
