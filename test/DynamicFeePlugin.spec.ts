import { Wallet, ZeroAddress } from 'ethers';
import bn from 'bignumber.js';
import { ethers } from 'hardhat';
import { loadFixture } from '@nomicfoundation/hardhat-network-helpers';
import { expect } from 'chai';
import { pluginFixture } from './shared/fixtures';
import { encodePriceSqrt } from './shared/utilities';

import { IAlgebraPool, DynamicFeePlugin, DynamicFeePluginFactory } from '../typechain-types';

describe('DynamicFeePlugin', () => {
  let wallet: Wallet, other: Wallet;

  let plugin: DynamicFeePlugin;
  let pluginFactory: DynamicFeePluginFactory;
  let pool: IAlgebraPool;

  async function initializeAtZeroTick(pool: IAlgebraPool) {
    await pool.initialize(encodePriceSqrt(1, 1));
  }

  before('prepare signers', async () => {
    [wallet, other] = await (ethers as any).getSigners();
  });

  beforeEach('deploy test DynamicFeePlugin', async () => {
    ({ plugin, pool, pluginFactory } = await loadFixture(pluginFixture));
  });

  describe('#BeofreSwap', async () => {
    it('returns right fee for zeroToOne swap', async () => {
      const poolSigner = new ethers.VoidSigner(await pool.getAddress(), ethers.provider)

      const result = await plugin.connect(poolSigner).beforeSwap.staticCall(
          ZeroAddress,
          ZeroAddress,
          true, // zeroToOne
          0,
          0,
          false,
          '0x',
      )

      expect(result[1]).to.equal(new bn('5000'));
      expect(result[2]).to.equal(new bn('10000'));
    });
    it('returns right fee for oneToZero swap', async () => {
      const poolSigner = new ethers.VoidSigner(await pool.getAddress(), ethers.provider)

      const result = await plugin.connect(poolSigner).beforeSwap.staticCall(
          ZeroAddress,
          ZeroAddress,
          false, // oneToZero
          0,
          0,
          false,
          '0x',
      )

      expect(result[1]).to.equal(new bn('10000'));
      expect(result[2]).to.equal(new bn('10000'));
    });
  });
  describe('#BeforeModifyPosition', async () => {
    it('returns right fee', async () => {
      const poolSigner = new ethers.VoidSigner(await pool.getAddress(), ethers.provider)

      const result = await plugin.connect(poolSigner).beforeModifyPosition.staticCall(
          ZeroAddress,
          ZeroAddress,
          0,
          0,
          0,
          '0x',
      )

      expect(result[1]).to.equal(new bn('10000'));
    });
  });
});
