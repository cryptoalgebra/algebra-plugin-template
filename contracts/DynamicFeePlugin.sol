// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import '@cryptoalgebra/integral-core/contracts/libraries/Plugins.sol';
import "@cryptoalgebra/integral-base-plugin/contracts/base/BasePlugin.sol";

contract DynamicFeePlugin is BasePlugin {
    /// Algebra specific stuff
    using Plugins for uint8;

    uint8 public constant override defaultPluginConfig =
    uint8(Plugins.BEFORE_SWAP_FLAG | Plugins.BEFORE_POSITION_MODIFY_FLAG | Plugins.DYNAMIC_FEE);

    /// Plugin variables
    uint24 public overrideFee;
    uint24 public pluginFee;

    constructor(
        address _pool,
        address _pluginFactory,
        uint24 _overrideFee,
        uint24 _pluginFee
    ) BasePlugin(_pool, _pluginFactory) {
        overrideFee = _overrideFee;
        pluginFee = _pluginFee;
    }

    function setParams(uint24 _overrideFee, uint24 _pluginFee) external {
        _authorize();
        overrideFee = _overrideFee;
        pluginFee = _pluginFee;
    }

    /// @dev Will be called regardless of flags
    function beforeInitialize(address, uint160) external override onlyPool returns (bytes4) {
        // Here we initially set the flags
        _updatePluginConfigInPool(defaultPluginConfig);
        return IAlgebraPlugin.beforeInitialize.selector;
    }

    /// @dev Considering defaultPluginConfig, is unused
    function afterInitialize(address, uint160, int24 tick) external override onlyPool returns (bytes4) {
        // Add this line to reset config since the hook is unused
        _updatePluginConfigInPool(defaultPluginConfig);
        return IAlgebraPlugin.afterInitialize.selector;
    }

    function beforeModifyPosition(address, address, int24, int24, int128, bytes calldata) external override onlyPool returns (bytes4, uint24) {
        return (IAlgebraPlugin.beforeModifyPosition.selector, pluginFee);
    }

    /// @dev Considering defaultPluginConfig, is unused
    function afterModifyPosition(address, address, int24, int24, int128, uint256, uint256, bytes calldata) external override onlyPool returns (bytes4) {
        // Add this line to reset config since the hook is unused
        _updatePluginConfigInPool(defaultPluginConfig);
        return IAlgebraPlugin.afterModifyPosition.selector;
    }

    function beforeSwap(
        address,
        address,
        bool zeroToOne,
        int256,
        uint160,
        bool,
        bytes calldata
    ) external override onlyPool returns (bytes4, uint24, uint24) {
        if (zeroToOne) {
            // If zeroToOne then we return override fee 2 times lower
            return (IAlgebraPlugin.beforeSwap.selector, overrideFee / 2, pluginFee);
        } else {
            return (IAlgebraPlugin.beforeSwap.selector, overrideFee, pluginFee);
        }
    }

    /// @dev Considering defaultPluginConfig, is unused
    function afterSwap(address, address, bool zeroToOne, int256, uint160, int256, int256, bytes calldata) external override onlyPool returns (bytes4) {
        // Add this line to reset config since the hook is unused
        _updatePluginConfigInPool(defaultPluginConfig);
        return IAlgebraPlugin.afterSwap.selector;
    }

    /// @dev Considering defaultPluginConfig, is unused
    function beforeFlash(address, address, uint256, uint256, bytes calldata) external override onlyPool returns (bytes4) {
        // Add this line to reset config since the hook is unused
        _updatePluginConfigInPool(defaultPluginConfig);
        return IAlgebraPlugin.beforeFlash.selector;
    }

    /// @dev Considering defaultPluginConfig, is unused
    function afterFlash(address, address, uint256, uint256, uint256, uint256, bytes calldata) external override onlyPool returns (bytes4) {
        // Add this line to reset config since the hook is unused
        _updatePluginConfigInPool(defaultPluginConfig);
        return IAlgebraPlugin.afterFlash.selector;
    }

    function _authorize() internal view override {
        require(msg.sender == pluginFactory, 'Unauthorized');
    }
}
