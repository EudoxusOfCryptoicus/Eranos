// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./Stakeable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";

contract Equity is Stakeable, ERC1155, ERC1155Burnable {
    uint256 public constant COMMON = 0;
    uint256 public constant PREFERRED = 1;

    constructor(string memory uri) ERC1155(uri) {
        _mint(msg.sender, COMMON, 10**9, "");
        _mint(msg.sender, PREFERRED, 10**6, "");
    }

    function stake(uint256 _tier, uint256 _amount) public {
        require(_tier == COMMON || _tier == PREFERRED, "Unknown equity tier");
        require(_amount < balanceOf(msg.sender, _tier), "You cannot stake more than you own");
        _stake(_tier, _amount);
        burn(msg.sender, _tier, _amount);
    }

    function withdrawStake(uint256 _tier, uint256 _amount, uint256 _index) public {
        uint256 amount = _withdrawStake(_tier, _amount, _index);
        _mint(msg.sender, _tier, _amount);
    }

    function mint(address owner, uint256 _tier, uint256 _amount) public {
        require(_tier == COMMON || _tier == PREFERRED, "Unknown equity tier");
        _mint(owner, _tier, _amount, "");
    }
}
