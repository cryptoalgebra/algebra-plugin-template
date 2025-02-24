import {ethers} from 'hardhat';
import {entrypointFixture, TokensFixture} from "./externalFixtures";
import AlgebraPool
  from "@cryptoalgebra/integral-core/artifacts/contracts/AlgebraPool.sol/AlgebraPool.json";
import {
    DynamicFeePluginFactory,
    DynamicFeePlugin,
    IAlgebraPool, IAlgebraFactory
} from '../../typechain-types';

type Fixture<T> = () => Promise<T>;
export const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';

interface PluginFixture extends TokensFixture {
    pluginFactory: DynamicFeePluginFactory,
    plugin: DynamicFeePlugin,
    pool: IAlgebraPool
}

export const pluginFixture: Fixture<PluginFixture> = async function (): Promise<PluginFixture> {
    const {customEntrypoint, factory, token0, token1} = await entrypointFixture();

    const pluginFactoryFactory = await ethers.getContractFactory('DynamicFeePluginFactory');
    const pluginFactory = (await pluginFactoryFactory.deploy(customEntrypoint)) as any as DynamicFeePluginFactory;

    await pluginFactory.createCustomPool(
        ZERO_ADDRESS,
        await token0.getAddress(),
        await token1.getAddress(),
        '0x'
    );

    const poolAddress = await factory.customPoolByPair(
        await pluginFactory.getAddress(),
        await token0.getAddress(),
        await token1.getAddress(),
    )

    const poolFactory = await ethers.getContractFactory(AlgebraPool.abi, AlgebraPool.bytecode);
    const pool = poolFactory.attach(poolAddress) as any as IAlgebraPool

    const pluginTypeFactory = await ethers.getContractFactory('DynamicFeePlugin');
    const pluginAddress = await pool.plugin();
    const plugin = pluginTypeFactory.attach(pluginAddress) as any as DynamicFeePlugin

    return {
        pluginFactory,
        plugin,
        pool,
        token0,
        token1
    };
};