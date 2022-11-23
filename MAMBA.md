# Environment variables

_For more information you can check out the [file](https://docs.blockscout.com/for-developers/information-and-settings/env-variables#full-env-variables-csv-file) explaining all existing blockscout env variables_

```bash
# Port at which blockscout will start
export PORT=8000

# Blockscout uses this to determine which implementation should be used. In case
# of mamba, this ALWAYS must be set to 'mamba'
export ETHEREUM_JSONRPC_VARIANT=mamba 

# Address of the json rpc service i.e. http://faucet.mamba.unzen 
export ETHEREUM_JSONRPC_HTTP_URL=http://localhost:8546

# PostgreSQL connection string
export DATABASE_URL=postgresql://blockscout:blockscout@localhost:5432/blockscout

# Logo text displayed at the top left corner of the website
export LOGO_TEXT="SIDECHAIN BLOCKEXPLORER"

# Name of the subnetwork i.e. "Mamba Staging"
export SUBNETWORK="Mamba Unzen"

# Other supported chains (will appear in the dropdown)
export SUPPORTED_CHAINS='[{
      "title": "Mamba Staging",
      "url": "http://explorer.mamba.unzen""
    }]'

# Normally Blockscout will display the message "Indexing Internal Transactions 
# - We're indexing this chain right now. Some of the counts may be inaccurate."
# until all internal transactions are indexed. For this process to be finished
# the `debug_traceTransaction` RPC endpoint must work properly. Setting this 
# variable to "true" will make this message disappear by force.
export INDEXER_DISABLE_INTERNAL_TRANSACTIONS_FETCHER=true

# Setting this variable will help if blockscout constantly logs errors like:
# `2022-11-23T19:38:04.131 application=indexer fetcher=coin_balance count=14 
# error_count=14 [error] failed to fetch: 
# 0xa86adb7a8331d9141144ab2b51ee4d496a547449@: (3) Execution error`
export INDEXER_DISABLE_ADDRESS_COIN_BALANCE_FETCHER=true
```


# Mamba JSON-RPC endpoints used by blockscout

- `eth_blockNumber`
- `eth_call`
- `eth_getBalance`
- `eth_getBlockByHash`
- `eth_getBlockByNumber`
- `eth_getTransactionByHash`
- `eth_getTransactionByBlockHashAndIndex`
- `eth_getTransactionReceipt`
- `eth_getUncleByBlockHashAndIndex`
- `eth_getLogs`
- `eth_getCode`
- `eth_subscribe`
- `txpool_content`


# Mamba data mappings
- When calling `eth_getUncleByBlockHashAndIndex`, `eth_getBlockByHash` or `eth_getBlockByNumber`, following transformations are performed to the `Transaction` objects in the response:
  *  When field `to` is missing, `"to": null` is added to the transaction object.
  * When field `v` is missing, but `chainId` and `yParity` are present, `"v": (35 + yParity + (chainId * 2))` is added to the transaction object.
  * When field `blockHash` is missing, `"blockHash": block["hash"]` is added to the transaction object. `block` is the block object of the block corresponding to the transaction.
  * When field `blockNumber` is missing, `"blockNumber": block["number"]` is added to the transaction object. `block` is the block object of the block corresponding to the transaction
  * When field `gasPrice` is missing and:
    - `maxFeePerGas` is not missing, `"gasPrice": maxFeePerGas` is added to the transaction object.
    - `maxFeePerGas` is missing, but `hash` is not, `eth_getTransactionByHash` is called and `"gasPrice": response["gasPrice"]` is added to the transaction object. `response` is the transaction object returned by the rpc call.