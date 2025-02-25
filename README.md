## Docs

The documentation page is located at: [https://docs.algebra.finance/](https://docs.algebra.finance/algebra-integral-documentation/algebra-integral-technical-reference/guides/plugin-development)

## Build

To install dependencies, you need to run the command in the root directory:
```
$ npm install
```


To compile contracts, you need to run the following command in the root directory:
```
$ npx hardhat compile
```

## Tests

Tests for plugin are run by the following command in the module folder:
```
$ npx hardhat test
```

## Deploy
Firstly you need to create `.env` file in the root directory of project as in `env.example`.

To deploy all modules in specific network:
```
$ npx hardhat run scripts\deploy.ts --network <network>
```
