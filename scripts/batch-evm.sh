#!/bin/bash

for((i=38;i<=138;i++));
do

echo $i

hallecli   tx evm   send  0x40c95592a4d7e9fe34bd9f4f3431a5bcc513223b 0   a9059cbb000000000000000000000000026c94c25066b473d92568ca83950877cb3581640000000000000000000000000000000000000000000000000000000000000064     --from mykey0 --gas 20000000   --gas-prices 10.0uhale      --home ./clicfg/ -y  -s $i -b  async

done 