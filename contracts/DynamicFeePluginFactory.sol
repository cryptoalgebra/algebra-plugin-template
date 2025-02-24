// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import './DynamicFeePlugin.sol';

import '@cryptoalgebra/integral-base-plugin/contracts/base/BasePluginFactory.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract DynamicFeePluginFactory is BasePluginFactory, Ownable {
    uint24 public defaultOverrideFee = 10000;
    uint24 public defaultPluginFee = 10000;

    constructor(address _entryPoint) BasePluginFactory(_entryPoint) {}

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
