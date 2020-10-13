#!/bin/bash

KEY="mykey"
KEY1="wade"
CHAINID=200812
MONIKER="mymoniker"

# remove existing chain environment, data and
rm -rf  ~/.halle*

make install

hallecli config keyring-backend test

# if mykey exists it should be deleted
hallecli keys add $KEY
hallecli keys add $KEY1

# Set moniker and chain-id for Ethermint (Moniker can be anything, chain-id must be an integer)
halled init $MONIKER --chain-id $CHAINID


os=`uname -a`
mac='Darwin'
if [[ $os =~ $mac ]];then

  sed -i ''  's/"max_gas": "-1"/"max_gas": "1000000000"/g'   ~/.halled/config/genesis.json
else
  sed -i 's/"max_gas": "-1"/"max_gas": "1000000000"/g'   ~/.halled/config/genesis.json
fi

# Set up config for CLI
hallecli config chain-id $CHAINID
hallecli config output json
hallecli config indent true
hallecli config trust-node true

# if $KEY exists it should be deleted


# Set moniker and chain-id for Ethermint (Moniker can be anything, chain-id must be an integer)

# Allocate genesis accounts (cosmos formatted addresses)
echo "add-genesis-account "
echo $(hallecli keys show $KEY -a)
halled add-genesis-account $(hallecli keys show $KEY -a)  100000000000000000000000000uhale
halled add-genesis-account $(hallecli keys show $KEY1 -a) 100000000000000000000000000uhale   # --vesting-amount 600hale  --vesting-start-time  1591781100   --vesting-end-time  1591781700

# Sign genesis transaction
halled gentx --name $KEY --keyring-backend test

# Collect genesis tx
halled collect-gentxs




# Run this to ensure everything worked and that the genesis file is setup correctly
halled validate-genesis

# Command to run the rest server in a different terminal/window
echo -e '\n\nRun this rest-server command in a different terminal/window:'
echo -e "hallecli rest-server --laddr \"tcp://localhost:8545\" --unlock-key $KEY --chain-id $CHAINID\n\n"

# Start the node (remove the --pruning=nothing flag if historical queries are not needed)
# halled start  --minimum-gas-prices  5.0uhale  --pruning=nothing --rpc.unsafe --log_level "main:info,state:info,mempool:info"   --rpc.laddr "tcp://0.0.0.0:26657"
halled start  --minimum-gas-prices  5.0uhale  --pruning-snapshot-every 10 --rpc.unsafe --log_level "main:info,state:info,mempool:info"   --rpc.laddr "tcp://0.0.0.0:26657"
