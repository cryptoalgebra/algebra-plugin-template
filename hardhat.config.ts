import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
const envconfig = require('dotenv')
const { ETHERSCAN_API_KEY, PK } = envconfig.parsed || {};

const config: HardhatUserConfig = {
  solidity: "0.8.20",
};

export default {
  networks: {
    mainnet: {
      url: `https://mainnet.infura.io`,
      chainId: 1,
      accounts: [`0x${PK || '1000000000000000000000000000000000000000000000000000000000000000'}`],
    },
  },
  solidity: config.solidity,
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: `${ETHERSCAN_API_KEY}`,
    customChains: []
  },
}
