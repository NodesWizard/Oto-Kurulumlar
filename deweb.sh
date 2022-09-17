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
DEWEB_PORT=14
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export DEWEB_CHAIN_ID=deweb-testnet-sirius" >> $HOME/.bash_profile
echo "export DEWEB_PORT=${DEWEB_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo -e "Your node name: \e[1m\e[32m$NODENAME\e[0m"
echo -e "Your wallet name: \e[1m\e[32m$WALLET\e[0m"
echo -e "Your chain name: \e[1m\e[32m$DEWEB_CHAIN_ID\e[0m"
echo -e "Your port: \e[1m\e[32m$DEWEB_PORT\e[0m"
echo '================================================='
sleep 2

echo -e "\e[1m\e[32m1. Updating packages... \e[0m" && sleep 1
# update
sudo apt update && sudo apt upgrade -y

echo -e "\e[1m\e[32m2. Installing dependencies... \e[0m" && sleep 1
# packages
sudo apt install curl build-essential git wget jq make gcc tmux -y

# install go
ver="1.18.2"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version

echo -e "\e[1m\e[32m3. Downloading and building binaries... \e[0m" && sleep 1
# download binary
cd $HOME
git clone https://github.com/deweb-services/deweb.git
cd deweb
git checkout v0.3.1
make build
sudo cp build/dewebd /usr/local/bin/dewebd

# config
dewebd config chain-id $DEWEB_CHAIN_ID
dewebd config keyring-backend test
dewebd config node tcp://localhost:${DEWEB_PORT}657

# init
dewebd init $NODENAME --chain-id $DEWEB_CHAIN_ID

# download genesis and addrbook
wget -qO $HOME/.deweb/config/genesis.json "https://raw.githubusercontent.com/deweb-services/deweb/main/genesis.json"

# set peers and seeds
SEEDS=""
PEERS="da6130e91acde648d23dda2847587f2cee86fb14@213.136.92.246:46656,f0232a1aa46bff410723655b2b2bdd785a30ec57@116.202.236.115:21046,857c09b91a95ae50946645293e6ab29c72dffb3a@65.108.43.116:56130"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.deweb/config/config.toml

# set custom ports
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${DEWEB_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${DEWEB_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${DEWEB_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${DEWEB_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${DEWEB_PORT}660\"%" $HOME/.deweb/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${DEWEB_PORT}317\"%; s%^address = \":8080\"%address = \":${DEWEB_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${DEWEB_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${DEWEB_PORT}091\"%" $HOME/.deweb/config/app.toml

# disable indexing
indexer="null"
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.deweb/config/config.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.deweb/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.deweb/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.deweb/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.deweb/config/app.toml

# set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0udws\"/" $HOME/.deweb/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.deweb/config/config.toml

# reset
dewebd tendermint unsafe-reset-all --home $HOME/.deweb

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# create service
sudo tee /etc/systemd/system/dewebd.service > /dev/null <<EOF
[Unit]
Description=deweb
After=network-online.target

[Service]
User=$USER
ExecStart=$(which dewebd) start --home $HOME/.deweb
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
sudo systemctl enable dewebd
sudo systemctl restart dewebd

echo '=============== SETUP FINISHED ==================='
echo -e 'To check logs: \e[1m\e[32mjournalctl -u dewebd -f -o cat\e[0m'
echo -e "To check sync status: \e[1m\e[32mcurl -s localhost:${DEWEB_PORT}657/status | jq .result.sync_info\e[0m"
