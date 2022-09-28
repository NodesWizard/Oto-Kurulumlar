#!/bin/bash

echo -e "\033[0;35m"
echo "  _   _  ____  _____  ______  _______          _______ ______         _____  _____    ";
echo " | \ | |/ __ \|  __ \|  ____|/ ____\ \        / /_   _|___  /   /\   |  __ \|  __ \   ";
echo " |  \| | |  | | |  | | |__  | (___  \ \  /\  / /  | |    / /   /  \  | |__) | |  | |  ";
echo " | |\  | |__| | |__| | |____ ____) |  \  /\  /   _| |_ / /__ / ____ \| | \ \| |__| |  ";
echo " |_| \_|\____/|_____/|______|_____/    \/  \/   |_____/_____/_/    \_\_|  \_\_____/   ";
echo -e "\e[0m"


sleep 2

# set vars
if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
OLLO_PORT=32
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export OLLO_CHAIN_ID=ollo-testnet-0" >> $HOME/.bash_profile
echo "export OLLO_PORT=${OLLO_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo -e "Your node name: \e[1m\e[32m$NODENAME\e[0m"
echo -e "Your wallet name: \e[1m\e[32m$WALLET\e[0m"
echo -e "Your chain name: \e[1m\e[32m$OLLO_CHAIN_ID\e[0m"
echo -e "Your port: \e[1m\e[32m$OLLO_PORT\e[0m"
echo '================================================='
sleep 2

echo -e "\e[1m\e[32m1. Updating packages... \e[0m" && sleep 1
# update
sudo apt update && sudo apt upgrade -y

echo -e "\e[1m\e[32m2. Installing dependencies... \e[0m" && sleep 1
# packages
sudo apt install curl build-essential git wget jq make gcc tmux chrony -y

# install go
if ! [ -x "$(command -v go)" ]; then
  ver="1.18.2"
  cd $HOME
  wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
  rm "go$ver.linux-amd64.tar.gz"
  echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
  source ~/.bash_profile
fi

echo -e "\e[1m\e[32m3. Downloading and building binaries... \e[0m" && sleep 1
# download binary
cd $HOME
git clone https://github.com/OllO-Station/ollo.git
cd ollo
make install

# config
ollod config chain-id $OLLO_CHAIN_ID
ollod config keyring-backend test
ollod config node tcp://localhost:${OLLO_PORT}657

# init
ollod init $NODENAME --chain-id $OLLO_CHAIN_ID

# download genesis and addrbook
curl https://raw.githubusercontent.com/OllO-Station/ollo/master/networks/ollo-testnet-0/genesis.json | jq .result.genesis > $HOME/.ollo/config/genesis.json

# set peers and seeds
SEEDS=""
PEERS="1be12d239ca70a906264de0f09e0ffa01c4211ba@138.201.136.49:26656,06658ccd5c119578fb662633234a2ef154881b94@18.144.61.148:26656,a77c2afc500569a453b7fb64c8a804878dc6e7be@65.108.127.215:26856,2eeb90b696ba9a62a8ad9561f39c1b75473515eb@77.37.176.99:26656,eaee85418b4fc3e7e2e298bb8deb5a8f49956859@5.9.13.234:26856,6e8c603e5eeefd4b83d0575951209c3b495848d6@65.108.69.68:26858,45acf9ea2f2d6a2a4b564ae53ea3004f902d3fb7@185.182.184.200:26656,62b5364abdfb7c0934afaddbd0704acf82127383@65.108.13.185:27060,f599dcd0a09d376f958910982d82351a6f8c178b@95.217.118.96:26878,e2b22ed4b00f37adafed6d711432f612821f5943@77.52.182.194:26656,d38fcf79871189c2c430473a7e04bd69aeb812c2@78.107.234.44:16656,0b4474bc96d72586e1be1860db731522d05fdeef@181.41.142.78:11523,1173fe561814f1ecb8b8f19d1769b87cd576897f@185.173.157.251:26656,489daf96446f104d822fae34cd4aa7a9b5cebf65@65.21.131.215:26626,8559490d439f774e39818c3a8f05a750c6ae6ff8@95.216.151.32:32657"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.ollo/config/config.toml

# set custom ports
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${OLLO_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${OLLO_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${OLLO_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${OLLO_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${OLLO_PORT}660\"%" $HOME/.ollo/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${OLLO_PORT}317\"%; s%^address = \":8080\"%address = \":${OLLO_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${OLLO_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${OLLO_PORT}091\"%" $HOME/.ollo/config/app.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.ollo/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.ollo/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.ollo/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.ollo/config/app.toml

# set minimum gas price and timeout commit
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0utollo\"/" $HOME/.ollo/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.ollo/config/config.toml

# reset
ollod tendermint unsafe-reset-all --home $HOME/.ollo

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# create service
sudo tee /etc/systemd/system/ollod.service > /dev/null <<EOF
[Unit]
Description=ollo
After=network-online.target

[Service]
User=$USER
ExecStart=$(which ollod) start --home $HOME/.ollo
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
sudo systemctl enable ollod
sudo systemctl restart ollod

sleep 2

sudo systemctl stop ollod
ollod tendermint unsafe-reset-all --home $HOME/.ollo --keep-addr-book

SNAP_RPC="https://node.ollo.zone:443"

LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH

PEERS="1be12d239ca70a906264de0f09e0ffa01c4211ba@138.201.136.49:26656,06658ccd5c119578fb662633234a2ef154881b94@18.144.61.148:26656,a77c2afc500569a453b7fb64c8a804878dc6e7be@65.108.127.215:26856,2eeb90b696ba9a62a8ad9561f39c1b75473515eb@77.37.176.99:26656,eaee85418b4fc3e7e2e298bb8deb5a8f49956859@5.9.13.234:26856,6e8c603e5eeefd4b83d0575951209c3b495848d6@65.108.69.68:26858,45acf9ea2f2d6a2a4b564ae53ea3004f902d3fb7@185.182.184.200:26656,62b5364abdfb7c0934afaddbd0704acf82127383@65.108.13.185:27060,f599dcd0a09d376f958910982d82351a6f8c178b@95.217.118.96:26878,e2b22ed4b00f37adafed6d711432f612821f5943@77.52.182.194:26656,d38fcf79871189c2c430473a7e04bd69aeb812c2@78.107.234.44:16656,0b4474bc96d72586e1be1860db731522d05fdeef@181.41.142.78:11523,1173fe561814f1ecb8b8f19d1769b87cd576897f@185.173.157.251:26656,489daf96446f104d822fae34cd4aa7a9b5cebf65@65.21.131.215:26626,8559490d439f774e39818c3a8f05a750c6ae6ff8@95.216.151.32:32657,ef56914e54fde621ca71d171c0711166d281b1bc@65.21.149.47:32657,969f3672d9d302c374102aa8ddb1c79672333127@95.216.149.119:32657"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.ollo/config/config.toml

sed -i -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.ollo/config/config.toml

sudo systemctl restart ollod

echo '=============== GURULUM BITMISTIR ==================='
echo -e 'BURADAN LOGLARA BAKABILIRSIN BABA: \e[1m\e[32mjournalctl -u ollod -f -o cat\e[0m'
echo -e "SYNC KONTROL ET BABA: \e[1m\e[32mcurl -s localhost:${OLLO_PORT}657/status | jq .result.sync_info\e[0m"
