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
GAIA_PORT=23
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export GAIA_CHAIN_ID=GAIA" >> $HOME/.bash_profile
echo "export GAIA_PORT=${GAIA_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo -e "Your node name: \e[1m\e[32m$NODENAME\e[0m"
echo -e "Your wallet name: \e[1m\e[32m$WALLET\e[0m"
echo -e "Your chain name: \e[1m\e[32m$GAIA_CHAIN_ID\e[0m"
echo -e "Your port: \e[1m\e[32m$GAIA_PORT\e[0m"
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
git clone https://github.com/Stride-Labs/gaia.git
cd gaia
git checkout 5b47714dd5607993a1a91f2b06a6d92cbb504721
make build
sudo cp $HOME/gaia/build/gaiad /usr/local/bin

# config
gaiad config chain-id $GAIA_CHAIN_ID
gaiad config keyring-backend test
gaiad config node tcp://localhost:${GAIA_PORT}657

# init
gaiad init $NODENAME --chain-id $GAIA_CHAIN_ID

# download genesis and addrbook
wget -qO $HOME/.gaia/config/genesis.json "https://raw.githubusercontent.com/Stride-Labs/testnet/main/poolparty/gaia/gaia_genesis.json"

# set peers and seeds
SEEDS=""
PEERS="bcb8420c5a3c67a9c4a4803c2a1d02d32f09eb8d@20.224.44.231:23656,9db59d9a6dd10ea2d5247432e0a371bbb97811ba@65.108.80.183:23656,245d766d00e6f7d1afdefc6e09d7be4314e8cc71@65.108.206.56:23656,1a5adae36c507e2f9354fcd2a44a483d3638ddf0@135.181.91.177:23656,1fb0892581455b14990238b09e4ee928c9ad57be@38.242.225.140:23656,3dcf50b01e256bee62aae9973a6b14fd59bb977f@188.166.104.216:23656,782cb61f5f416cf637ef71d0d80d5cbda7846a94@135.181.151.107:26656,1f22295ecc9c2164a4cb1130c340fdd2e07ed803@65.108.131.14:23656,4225449b63e692650f16c0fb897a9d4f3b7b938b@167.235.73.132:23658,2b43910f82d55dc1ad2744658d4a0e2bf4b21f98@95.216.220.64:23658,789ae52e1ef1047a73a8f64b8eb3fc2bb54f8ed0@65.21.254.161:23658,b01f4bf8d372a47e727d604dadd13ffbd2bfa8ce@95.216.210.104:23658,78a0aa68be8a944637e70aa655fbc9ab46192ecf@65.108.220.117:23658,a573c23191a5114b7c13c555227b9cd5dcc12fb4@65.108.249.29:23658,033f317d879eecd733c9af2a6a2159cb4ea24150@78.47.217.149:23658,830aab1ae690b406bbec93cf0e01ca7bba5870ba@78.47.124.253:23658,7a913c33c7a16ee160a403c170d6d1f34d97a4f0@78.47.105.73:23658,f86ab676050b8582423f835c8d14eebd648e1de4@78.47.131.222:23658,e9c098097e98265f39c37a7cb95708feb7a39186@65.21.144.88:23658,5f5ca9ac05878e93e65c48ac08311405a8ef5b2a@195.201.18.93:23658,b1070455d95c7a8b874f77201e072507f5b982e5@65.108.250.219:23658"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.gaia/config/config.toml

# set custom ports
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${GAIA_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${GAIA_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${GAIA_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${GAIA_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${GAIA_PORT}660\"%" $HOME/.gaia/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${GAIA_PORT}317\"%; s%^address = \":8080\"%address = \":${GAIA_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${GAIA_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${GAIA_PORT}091\"%" $HOME/.gaia/config/app.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.gaia/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.gaia/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.gaia/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.gaia/config/app.toml

# set minimum gas price and timeout commit
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0uatom\"/" $HOME/.gaia/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.gaia/config/config.toml

# reset
gaiad tendermint unsafe-reset-all --home $HOME/.gaia

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# create service
sudo tee /etc/systemd/system/gaiad.service > /dev/null <<EOF
[Unit]
Description=gaia
After=network-online.target

[Service]
User=$USER
ExecStart=$(which gaiad) start --home $HOME/.gaia
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
sudo systemctl enable gaiad
sudo systemctl restart gaiad

echo '=============== kurulum bitti . www.nodeswizard.com ==================='
echo -e 'logları kontrol et: \e[1m\e[32mjournalctl -u gaiad -f -o cat\e[0m'
echo -e "senkarizasyon kontrol: \e[1m\e[32mcurl -s localhost:${GAIA_PORT}657/status | jq .result.sync_info\e[0m"
