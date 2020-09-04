# 1. hallecli init
rm -rf ~/.halle*


hallecli config keyring-backend test
hallecli config chain-id 200812
hallecli config output json
hallecli config indent true
hallecli config trust-node true

# 2. init
rm -rf testnet/*
halled init node0 --chain-id 200812 --home testnet/node0
halled init node1 --chain-id 200812 --home testnet/node1
halled init node2 --chain-id 200812 --home testnet/node2
halled init node3 --chain-id 200812 --home testnet/node3
halled init node4 --chain-id 200812 --home testnet/node4
halled init node5 --chain-id 200812 --home testnet/node5
halled init node6 --chain-id 200812 --home testnet/node6
halled init node7 --chain-id 200812 --home testnet/node7
halled init node8 --chain-id 200812 --home testnet/node8

os=`uname -a`
mac='Darwin'
if [[ $os =~ $mac ]];then

  sed -i ''  's/"max_gas": "-1"/"max_gas": "1000000000"/g'   testnet/node0/config/genesis.json
  sed -i ''  's/"max_gas": "-1"/"max_gas": "1000000000"/g'   testnet/node1/config/genesis.json
  sed -i ''  's/"max_gas": "-1"/"max_gas": "1000000000"/g'   testnet/node2/config/genesis.json
  sed -i ''  's/"max_gas": "-1"/"max_gas": "1000000000"/g'   testnet/node3/config/genesis.json
  sed -i ''  's/"max_gas": "-1"/"max_gas": "1000000000"/g'   testnet/node4/config/genesis.json
  sed -i ''  's/"max_gas": "-1"/"max_gas": "1000000000"/g'   testnet/node5/config/genesis.json
  sed -i ''  's/"max_gas": "-1"/"max_gas": "1000000000"/g'   testnet/node6/config/genesis.json

else
  sed -i   's/"max_gas": "-1"/"max_gas": "1000000000"/g'   testnet/node0/config/genesis.json
  sed -i   's/"max_gas": "-1"/"max_gas": "1000000000"/g'   testnet/node1/config/genesis.json
  sed -i   's/"max_gas": "-1"/"max_gas": "1000000000"/g'   testnet/node2/config/genesis.json
  sed -i   's/"max_gas": "-1"/"max_gas": "1000000000"/g'   testnet/node3/config/genesis.json
  sed -i   's/"max_gas": "-1"/"max_gas": "1000000000"/g'   testnet/node4/config/genesis.json
  sed -i   's/"max_gas": "-1"/"max_gas": "1000000000"/g'   testnet/node5/config/genesis.json
  sed -i   's/"max_gas": "-1"/"max_gas": "1000000000"/g'   testnet/node6/config/genesis.json
fi




# 3. create genesis accounts
hallecli keys add mykey0
hallecli keys add mykey1
hallecli keys add mykey2
hallecli keys add mykey3
hallecli keys add mykey4
hallecli keys add mykey5
hallecli keys add mykey6


# 4. add genesis accounts to genesis.json
halled add-genesis-account $(hallecli keys show mykey0 -a) 10000000000000000000000000000uhale --home testnet/node0
halled add-genesis-account $(hallecli keys show mykey1 -a) 10000000000000000000000000000uhale --home testnet/node0
halled add-genesis-account $(hallecli keys show mykey2 -a) 10000000000000000000000000000uhale --home testnet/node0
halled add-genesis-account $(hallecli keys show mykey3 -a) 10000000000000000000000000000uhale --home testnet/node0
halled add-genesis-account $(hallecli keys show mykey4 -a) 10000000000000000000000000000uhale --home testnet/node0
halled add-genesis-account $(hallecli keys show mykey5 -a) 10000000000000000000000000000uhale --home testnet/node0
halled add-genesis-account $(hallecli keys show mykey6 -a) 10000000000000000000000000000uhale --home testnet/node0


# halled add-genesis-account $(hallecli keys show mykey1 -a) 1000000000000000000hale --home testnet/node1
# halled add-genesis-account $(hallecli keys show mykey2 -a) 1000000000000000000hale --home testnet/node2
halled add-genesis-account $(hallecli keys show mykey1 -a) 10000000000000000000000000000uhale --home testnet/node1
halled add-genesis-account $(hallecli keys show mykey2 -a) 10000000000000000000000000000uhale --home testnet/node2
halled add-genesis-account $(hallecli keys show mykey3 -a) 10000000000000000000000000000uhale --home testnet/node3
halled add-genesis-account $(hallecli keys show mykey4 -a) 10000000000000000000000000000uhale --home testnet/node4
halled add-genesis-account $(hallecli keys show mykey5 -a) 10000000000000000000000000000uhale --home testnet/node5
halled add-genesis-account $(hallecli keys show mykey6 -a) 10000000000000000000000000000uhale --home testnet/node6



# 5. create gentxs
halled gentx --name mykey0 --home testnet/node0 --ip 192.168.20.2 --node-id $(halled tendermint show-node-id --home testnet/node0) --keyring-backend test
halled gentx --name mykey1 --home testnet/node1 --ip 192.168.20.3 --node-id $(halled tendermint show-node-id --home testnet/node1) --keyring-backend test
halled gentx --name mykey2 --home testnet/node2 --ip 192.168.20.4 --node-id $(halled tendermint show-node-id --home testnet/node2) --keyring-backend test
halled gentx --name mykey3 --home testnet/node3 --ip 192.168.20.5 --node-id $(halled tendermint show-node-id --home testnet/node3) --keyring-backend test
halled gentx --name mykey4 --home testnet/node4 --ip 192.168.20.6 --node-id $(halled tendermint show-node-id --home testnet/node4) --keyring-backend test
halled gentx --name mykey5 --home testnet/node5 --ip 192.168.20.7 --node-id $(halled tendermint show-node-id --home testnet/node5) --keyring-backend test
halled gentx --name mykey6 --home testnet/node6 --ip 192.168.20.8 --node-id $(halled tendermint show-node-id --home testnet/node6) --keyring-backend test


# 6. collect-gentxs to genesis.json
cp testnet/node1/config/gentx/* testnet/node0/config/gentx/
cp testnet/node2/config/gentx/* testnet/node0/config/gentx/
cp testnet/node3/config/gentx/* testnet/node0/config/gentx/
cp testnet/node4/config/gentx/* testnet/node0/config/gentx/
cp testnet/node5/config/gentx/* testnet/node0/config/gentx/
cp testnet/node6/config/gentx/* testnet/node0/config/gentx/


halled collect-gentxs --home testnet/node0

os=`uname -a`
mac='Darwin'
if [[ $os =~ $mac ]];then
  sed -i ''  's/"max_gas": "-1"/"max_gas": "1000000000"/g'  testnet/node0/config/genesis.json
else
  sed -i 's/"max_gas": "-1"/"max_gas": "1000000000"/g'  testnet/node0/config/genesis.json
fi



# 7. collect node1 and node2 genesis.json gentxs, copy to node0 genesis.json gentxs, copy node0 genesis.json to replace others
rm -f testnet/node1/config/genesis.json
rm -f testnet/node2/config/genesis.json
rm -f testnet/node3/config/genesis.json
rm -f testnet/node4/config/genesis.json
rm -f testnet/node5/config/genesis.json
rm -f testnet/node6/config/genesis.json

cp testnet/node0/config/genesis.json testnet/node1/config/
cp testnet/node0/config/genesis.json testnet/node2/config/
cp testnet/node0/config/genesis.json testnet/node3/config/
cp testnet/node0/config/genesis.json testnet/node4/config/
cp testnet/node0/config/genesis.json testnet/node5/config/
cp testnet/node0/config/genesis.json testnet/node6/config/
cp testnet/node0/config/genesis.json testnet/node7/config/
cp testnet/node0/config/genesis.json testnet/node8/config/


# 8. config each node's config.toml persistent_peers to the other two node's node-id@node-ip:26656
# os=`uname -a`
# mac='Darwin'
peers=`halled tendermint show-node-id --home testnet/node0`@192.168.20.2:26656,`halled tendermint show-node-id --home testnet/node1`@192.168.20.3:26656,`halled tendermint show-node-id --home testnet/node2`@192.168.20.4:26656,`halled tendermint show-node-id --home testnet/node3`@192.168.20.5:26656,`halled tendermint show-node-id --home testnet/node4`@192.168.20.6:26656,`halled tendermint show-node-id --home testnet/node5`@192.168.20.7:26656,`halled tendermint show-node-id --home testnet/node6`@192.168.20.8:26656
if [[ $os =~ $mac ]];then
    gsed -i '175,175d' testnet/node0/config/config.toml
    gsed -i "174a persistent_peers = \"$peers\"" testnet/node0/config/config.toml
    gsed -i '175,175d' testnet/node1/config/config.toml
    gsed -i "174a persistent_peers = \"$peers\"" testnet/node1/config/config.toml
    gsed -i '175,175d' testnet/node2/config/config.toml
    gsed -i "174a persistent_peers = \"$peers\"" testnet/node2/config/config.toml
    gsed -i '175,175d' testnet/node3/config/config.toml
    gsed -i "174a persistent_peers = \"$peers\"" testnet/node3/config/config.toml
    gsed -i '175,175d' testnet/node4/config/config.toml
    gsed -i "174a persistent_peers = \"$peers\"" testnet/node4/config/config.toml
    gsed -i '175,175d' testnet/node5/config/config.toml
    gsed -i "174a persistent_peers = \"$peers\"" testnet/node5/config/config.toml
    gsed -i '175,175d' testnet/node6/config/config.toml
    gsed -i "174a persistent_peers = \"$peers\"" testnet/node6/config/config.toml
    gsed -i '175,175d' testnet/node7/config/config.toml
    gsed -i "174a persistent_peers = \"$peers\"" testnet/node7/config/config.toml
    gsed -i '175,175d' testnet/node8/config/config.toml
    gsed -i "174a persistent_peers = \"$peers\"" testnet/node8/config/config.toml
else
    sed -i '175,175d' testnet/node0/config/config.toml
    sed -i "174a persistent_peers = \"$peers\"" testnet/node0/config/config.toml
    sed -i '175,175d' testnet/node1/config/config.toml
    sed -i "174a persistent_peers = \"$peers\"" testnet/node1/config/config.toml
    sed -i '175,175d' testnet/node2/config/config.toml
    sed -i "174a persistent_peers = \"$peers\"" testnet/node2/config/config.toml
    sed -i '175,175d' testnet/node3/config/config.toml
    sed -i "174a persistent_peers = \"$peers\"" testnet/node3/config/config.toml
    sed -i '175,175d' testnet/node4/config/config.toml
    sed -i "174a persistent_peers = \"$peers\"" testnet/node4/config/config.toml
    sed -i '175,175d' testnet/node5/config/config.toml
    sed -i "174a persistent_peers = \"$peers\"" testnet/node5/config/config.toml
    sed -i '175,175d' testnet/node6/config/config.toml
    sed -i "174a persistent_peers = \"$peers\"" testnet/node6/config/config.toml
    sed -i '175,175d' testnet/node7/config/config.toml
    sed -i "174a persistent_peers = \"$peers\"" testnet/node7/config/config.toml
    sed -i '175,175d' testnet/node8/config/config.toml
    sed -i "174a persistent_peers = \"$peers\"" testnet/node8/config/config.toml
fi

# 9. copy hallecli to testet
mkdir testnet/clicfg
cp -R ~/.hallecli/* testnet/clicfg

# 9. start each node, halled start --home node* --rpc.unsafe --log_level "main:info,state:info,mempool:info"
echo -e "\n------Enjoy it!------"
