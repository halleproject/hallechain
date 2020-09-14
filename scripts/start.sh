#!/bin/sh

if [ -n "$1" ]
then
	halled start   --pruning=nothing   --minimum-gas-prices  5.0uhale   --home  $1  --log_level "main:info,state:info,mempool:info"  --rpc.laddr "tcp://0.0.0.0:26657" &

	sleep 5

  hallecli rest-server --laddr tcp://0.0.0.0:8545 --unlock-key mykey0 --chain-id 200812 --trace --home clicfg/ --unsafe-cors=true &
  tail -f /dev/null

	fi
