# Blockscout


## 1. Notice

As of 2023, IOG will no longer be updating or maintaining this repo.

After three months of experimentation with the proof-of-concept EVM sidechain testnet, we have gathered valuable learnings from this experience and this innovative playground. New use cases and functionality were tested, feedback from the community was gathered, and we are now shifting our focus back to the strategic evolution of our sidechains approach.

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
### Building with Nix
Requirements:  
[Nix](https://github.com/DeterminateSystems/nix-installer#usage)  
The above installer is unofficial but already has flakes enabled. On other installations, ensure flakes in enabled in `nix.conf` or pass nix the flag `--extra-experimental-features 'nix-command flakes'`  
Build:
```
nix build .#blockscout
```
The build is symlinked as `result` in the directory

## 3. Next steps

If you decide to investigate further, start with the [development instructions](DEVELOPMENT.md) and go from there.
## 4. Known issues
See the [Known issues document](KNOWN-ISSUES.md).