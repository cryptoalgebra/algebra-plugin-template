// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import './DynamicFeePlugin.sol';

import '@cryptoalgebra/abstract-plugin/contracts/AbstractCustomPluginFactory.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract DynamicFeePluginFactory is AbstractCustomPluginFactory, Ownable {
    uint24 public defaultOverrideFee = 10000;
    uint24 public defaultPluginFee = 10000;

    constructor(address _entryPoint) AbstractCustomPluginFactory(_entryPoint) {}

    function setDefaultParams(uint24 _defaultOverrideFee, uint24 _defaultPluginFee) onlyOwner external {
        defaultOverrideFee = _defaultOverrideFee;
        defaultPluginFee = _defaultPluginFee;
    }

    function setTickSpacing(address pool, int24 newTickSpacing) onlyOwner external {
        IAlgebraCustomPoolEntryPoint(entryPoint).setTickSpacing(pool, newTickSpacing);
    }

    function setPlugin(address pool, address newPluginAddress) onlyOwner external {
        IAlgebraCustomPoolEntryPoint(entryPoint).setPlugin(pool, newPluginAddress);
    }

    function setPluginConfig(address pool, uint8 newConfig) onlyOwner external {
        IAlgebraCustomPoolEntryPoint(entryPoint).setPluginConfig(pool, newConfig);
    }

    function setFee(address pool, uint16 newFee) onlyOwner external {
        IAlgebraCustomPoolEntryPoint(entryPoint).setFee(pool, newFee);
    }

    function collectPluginFeeFromPlugin(address plugin, address token, uint256 amount, address recipient) onlyOwner external{
        IAbstractPlugin(plugin).collectPluginFee(token, amount, recipient);
    }

    function _createPlugin(address pool) internal override returns (address) {
        DynamicFeePlugin plugin = new DynamicFeePlugin(
            pool,
            address(this),
            defaultOverrideFee,
            defaultPluginFee
        );
        return address(plugin);
    }
    
}
