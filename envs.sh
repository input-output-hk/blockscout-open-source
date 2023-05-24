export ETHEREUM_JSONRPC_VARIANT="SC_EVM"
export ETHEREUM_JSONRPC_HTTP_URL="http://localhost:8546"
export DATABASE_URL=postgresql://blockscout:blockscout@localhost:5432/blockscout2
export INDEXER_DISABLE_ADDRESS_COIN_BALANCE_FETCHER=true

export LOGO_TEXT="SIDECHAIN BLOCKEXPLORER"
# export LOGO=/images/iohk-logo.png
# export LOGO_FOOTER=/images/iohk-logo.png
export SUBNETWORK=SC_EVM
export SUPPORTED_CHAINS='[{
      "title": "SC_EVM local",
      "url": http://localhost:8546
    }]'

export INDEXER_DISABLE_INTERNAL_TRANSACTIONS_FETCHER=true