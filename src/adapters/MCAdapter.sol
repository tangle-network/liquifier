// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.19;

import { Adapter } from "core/adapters/Adapter.sol";
import { IMCStaking } from "core/adapters/interfaces/IMCStaking.sol";
import { ERC20 } from "solmate/tokens/ERC20.sol";
import { SafeTransferLib } from "solmate/utils/SafeTransferLib.sol";
import { IERC165 } from "core/interfaces/IERC165.sol";

IMCStaking constant MCStaking = IMCStaking(address(1));
ERC20 constant MCToken = ERC20(address(2));


contract MCAdapter is Adapter {
    using SafeTransferLib for ERC20;

    function previewDeposit(address /*_validator*/, uint256 _assets) external pure returns (uint256) {
        return _assets;
    }

    function unlockMaturity(uint256 /*_unlockID*/) external pure returns (uint256) {
        // assets could be withdrawn at any time since the staking begins
        return 0;
    }

    function unlockTime() external pure returns (uint256) {
        // there is no concept of cooldown
        return 0;
    }

    function currentTime() external view returns (uint256) {
        return block.timestamp;
    }

    function withdraw(address /*_validator*/, uint256 /*_unlockID*/) external pure returns (uint256 amount) {
        // MC staking has no concept of unbonding nor cooldown, deposits can be withdrawn right away
        return 0;
    }

    function unstake(address _validator, uint256 _amount) external returns (uint256) {
        MCStaking.withdraw(_validator, _amount);
        return _amount;
    }

    function previewWithdraw(uint256/*unlockID*/) external view returns (uint256) {
        // MC staking does not have cooldowns nor unbonding, everything is withdrawn in unstake
        // return total amount of staked tokens
        return MCStaking.stakerTotalDeposit(address(this));
    }

    function stake(address _validator, uint256 _amount) external returns (uint256) {
        MCToken.safeApprove(address(MCStaking), _amount);
        MCStaking.stake(_validator, _amount, address(this));
        return _amount;
    }

    function rebase(address /*validator*/, uint256/*currentStake*/) external returns (uint256) {
        // MC staking has a strict rebase schedule based on time passed, so no arguments needed.
        return MCStaking.rebase();
    }

    function isValidator(address _validator) external view returns (bool) {
        return MCStaking.isNode(_validator);
    }

    function supportsInterface(bytes4 _interfaceId) external pure override returns (bool) {
        return _interfaceId == type(Adapter).interfaceId || _interfaceId == type(IERC165).interfaceId;
    }
}