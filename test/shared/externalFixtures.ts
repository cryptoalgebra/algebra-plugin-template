import {ethers} from 'hardhat';
import {IAlgebraCustomPoolEntryPoint, IAlgebraFactory, IAlgebraPoolDeployer, TestERC20} from '../../typechain-types';
import AlgebraFactoryJson
  from "@cryptoalgebra/integral-core/artifacts/contracts/AlgebraFactory.sol/AlgebraFactory.json";
import AlgebraCustomPoolEntryPointJson
  from "@cryptoalgebra/integral-periphery/artifacts/contracts/AlgebraCustomPoolEntryPoint.sol/AlgebraCustomPoolEntryPoint.json"
import AlgebraPoolDeployer
  from "@cryptoalgebra/integral-core/artifacts/contracts/AlgebraPoolDeployer.sol/AlgebraPoolDeployer.json"
import {getCreateAddress} from "ethers";

type Fixture<T> = () => Promise<T>;

export interface TokensFixture {
  token0: TestERC20;
  token1: TestERC20;
}

export async function tokensFixture(): Promise<TokensFixture> {
  const tokenFactory = await ethers.getContractFactory('TestERC20');
  const tokenA = (await tokenFactory.deploy(2n ** 255n)) as any as TestERC20 & { address: string };
  const tokenB = (await tokenFactory.deploy(2n ** 255n)) as any as TestERC20 & { address: string };

  tokenA.address = await tokenA.getAddress();
  tokenB.address = await tokenB.getAddress();

  const [token0, token1] = [tokenA, tokenB].sort((_tokenA, _tokenB) => (_tokenA.address.toLowerCase() < _tokenB.address.toLowerCase() ? -1 : 1));

  return { token0, token1 };
}

interface EntrypointFixture extends TokensFixture{
    factory: IAlgebraFactory;
    customEntrypoint: IAlgebraCustomPoolEntryPoint;
    poolDeployer: IAlgebraPoolDeployer;
}

export const entrypointFixture: Fixture<EntrypointFixture> = async function (): Promise<EntrypointFixture> {
    const {token0, token1} = await tokensFixture();

    const [deployer] = await ethers.getSigners();
    // precompute
    const poolDeployerAddress = getCreateAddress({
      from: deployer.address,
      nonce: (await ethers.provider.getTransactionCount(deployer.address)) + 1,
    });

    const v3FactoryFactory = await ethers.getContractFactory(AlgebraFactoryJson.abi, AlgebraFactoryJson.bytecode);
    const _factory = (await v3FactoryFactory.deploy(poolDeployerAddress)) as any as IAlgebraFactory;

    const poolDeployerFactory = await ethers.getContractFactory(AlgebraPoolDeployer.abi, AlgebraPoolDeployer.bytecode);
    const _poolDeployer = (await poolDeployerFactory.deploy(_factory)) as any as IAlgebraPoolDeployer;

    const customEntrypointFactory = await ethers.getContractFactory(AlgebraCustomPoolEntryPointJson.abi, AlgebraCustomPoolEntryPointJson.bytecode);
    const _customEntrypoint = (await customEntrypointFactory.deploy(_factory)) as any as IAlgebraCustomPoolEntryPoint;

    const role = await (_factory as any).CUSTOM_POOL_DEPLOYER()
    await (_factory as any).grantRole(role, await _customEntrypoint.getAddress())

    return {
        factory: _factory,
        customEntrypoint: _customEntrypoint,
        poolDeployer: _poolDeployer,
        token0,
        token1
    };
};