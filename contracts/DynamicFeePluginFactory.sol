// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import './DynamicFeePlugin.sol';

import '@cryptoalgebra/integral-periphery/contracts/interfaces/IAlgebraCustomPoolEntryPoint.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract DynamicFeePluginFactory is Ownable {
    address public immutable entryPoint;

    uint24 public defaultOverrideFee = 10000;
    uint24 public defaultPluginFee = 10000;

    mapping(address poolAddress => address pluginAddress) public pluginByPool;

    constructor(address _entryPoint) {
        entryPoint = _entryPoint;
    }

    function createCustomPool(
        address creator,
        address tokenA,
        address tokenB,
        bytes calldata data
    ) external returns (address customPool) {
        return IAlgebraCustomPoolEntryPoint(entryPoint).createCustomPool(address(this), creator, tokenA, tokenB, data);
    }

    function beforeCreatePoolHook(address pool, address, address, address, address, bytes calldata) external returns (address) {
        require(msg.sender == entryPoint);
        return _createPlugin(pool);
    }

    function afterCreatePoolHook(address, address, address) external view {
        require(msg.sender == entryPoint);
    }

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

    function _createPlugin(address pool) internal returns (address) {
        require(pluginByPool[pool] == address(0), 'Already created');
        DynamicFeePlugin plugin = new DynamicFeePlugin(
            pool,
            address(this),
            defaultOverrideFee,
            defaultPluginFee
        );
        pluginByPool[pool] = address(plugin);
        return address(plugin);
    }
}
