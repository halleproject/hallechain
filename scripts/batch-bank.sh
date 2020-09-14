#!/bin/bash

#ii=$(hallecli  query account $(hallecli keys show mykey0  -a --home ./clicfg/)   --home ./clicfg/ |sed 's/,/\n/g' | grep "sequence" | sed 's/:/\n/g' | sed '1d' | sed 's/}//g')

ii=$(hallecli  query account $(hallecli keys show mykey0  -a )  |sed 's/,/\n/g' | grep "sequence" | sed 's/:/\n/g' | sed '1d' | sed 's/}//g')


for((i=ii;i<=ii+10;i++));
do

echo $i
#hallecli tx send  mykey0  halle1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqh9dg42   100uhale  --gas 800000 --gas-prices 5.1uhale     -s $i -y  -b  async  --home ./clicfg/
hallecli tx send  mykey0  halle1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqh9dg42   100uhale  --gas 800000 --gas-prices 5.1uhale     -s $i -y  -b  async

done
