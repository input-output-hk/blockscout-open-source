export ETHEREUM_JSONRPC_VARIANT=mamba
export ETHEREUM_JSONRPC_HTTP_URL=http://faucet.mamba.unzen
export DATABASE_URL=postgresql://blockscout:blockscout@localhost:5432/blockscout2
export INDEXER_DISABLE_ADDRESS_COIN_BALANCE_FETCHER=true

export LOGO_TEXT="SIDECHAIN BLOCKEXPLORER"
# export LOGO=/images/iohk-logo.png
# export LOGO_FOOTER=/images/iohk-logo.png
export SUBNETWORK=Mamba
export SUPPORTED_CHAINS='[{
      "title": "Mamba Staging",
      "url": "http://explorer.mamba.unzen"
    }]'

export INDEXER_DISABLE_INTERNAL_TRANSACTIONS_FETCHER=true