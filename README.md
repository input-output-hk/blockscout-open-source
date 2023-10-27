# Blockscout


## 1. Notice

IOG will no longer be updating or maintaining this repository. 

After three months of experimentation with the proof-of-concept EVM sidechain testnet, the team gathered valuable learnings from this experience and this playground. New use cases and functionality were tested, feedback from the community was gathered, and we are now continuing to develop the interoperability solutions in line with the partnerchains framework announced at the Cardano Summit 2023.

All information included in this repository is considered publicly available and is free to be leveraged by developers to fork it to build and experiment with their own EVM sidechain solution. Should you have any questions, please reach out to the team on the [IOG Discord server](https://discord.com/invite/inputoutput).

## 2. Description
This repo was forked from https://github.com/blockscout/blockscout, and if you wish to contribute you should make your contribution there, following the rules laid out in its Readme file.   
### General
BlockScout provides a comprehensive, easy-to-use interface for users to view, confirm, and inspect transactions on EVM (Ethereum Virtual Machine) blockchains.    

The explorer in this repository is a Blockexplorer that is configured and ready to work with the SC_EVM chain and EVM-compatible chains. The SC_EVM chain is available to the public for education and demonstration in [this public GitHub repository](https://github.com/input-output-hk/sc-evm).
### Modifications  
The following changes were made to this repo for the particular use case of the SC_EVM requirements:  
- Modifications were done on endpoint conversions from a PoW to a PoS - see [SC_EVM.md](SC_EVM.md)  
- Some name changes such as miner to validator
- Pruned some menu sections not relevant for this chain setup
- Included nix flakes to build under NixOS
- Modified color palettes.
### Building with Docker

Requirements:

- [Docker](https://docs.docker.com/get-docker/)
- [docker-compose](https://docs.docker.com/compose/)

**Note.** Make sure, that [SC_EVM](https://github.com/input-output-hk/sc-evm) node has JSON RPC Client at port 8545 running.

Build and start locally:

```bash
cd docker-compose
docker-compose up --build
```
Blockscout UI will be available at `http://localhost:4000`

## 3. Next steps

If you decide to investigate further, start with the [development instructions](DEVELOPMENT.md) and go from there.
## 4. Known issues
See the [Known issues document](KNOWN-ISSUES.md).