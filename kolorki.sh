set -e
mix phx.digest.clean                                                                           
mix compile                                                                                  
cd apps/block_scout_web/assets; npm install && node_modules/webpack/bin/webpack.js --mode production; cd -                                                                                                                                                                                 
cd apps/explorer && npm install; cd -                                                          
mix phx.digest
