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
PEERS="2ee845a5818be951f9139b81ff19db63e741c353@20.29.16.128:23656,da87076fe563a8319270c4aef77be81126967a69@188.166.21.73:23656,245d766d00e6f7d1afdefc6e09d7be4314e8cc71@65.108.206.56:23656,31dfc7a5acf96f338bd3a39ff51a4f23220d3a05@95.214.55.4:26666,fdadcd891370fce4049a73f821939ce36ffc0539@78.47.131.222:23656,2b79dae3d3289a35d54973a4db35e2e0ade87bb7@65.108.238.183:23656,1a5adae36c507e2f9354fcd2a44a483d3638ddf0@135.181.91.177:23656,60f0d2f62ee9c7b953c3a9cdf5eab42de310e89e@149.102.142.102:23656,3eecd0978c428c31675a35af8da059e4943c0055@34.135.227.50:23656,ce2e3cc68afee1e6ce98d8e24ac142593137fbe2@38.242.215.136:23656,872e7d984253af34b9f7b7a3d1c729cdae7cbf53@161.97.143.31:23656,7a5b90ed09a1f6e4ac755b86351bcf90f274ffaa@159.223.70.48:23656,edb2864997e5b68194c72f2e25c0c83566f5f186@162.55.180.238:26656,e20dfff35e0c89cc06ff6df9b63fd75de7665277@194.163.146.64:23656,36548633554e391db8609f48225bd4282b3221a7@194.163.146.8:23656,015254cc413cd447266554162bf35b1881703cfe@194.233.67.89:23656,60201ea184c71542183592c6b9d1a69c8025192f@188.166.58.241:23656,d39a8df130cb471f5e850a7df1083b3f03a67244@185.252.235.89:23656,e737ea2060ffa77840f88a324efd1a29d37d0fc1@164.92.76.24:23656,ea62913113f16de1bf58bb244d44401f42f85b6b@135.181.131.116:36656,45d9c593f8e44989f3b0705f464c2212a53ba3fc@38.242.133.84:23656,3ece04931935dbef068543fe3130494fa5db9b0c@188.166.72.156:23656,b1577e9bdb4964ee3f875cbc5eae555bf04c68aa@45.10.154.148:23656,f70f96f1601c11f575895fb4cb836a377ee40a54@195.201.41.223:23656,9db59d9a6dd10ea2d5247432e0a371bbb97811ba@65.108.80.183:23656,30b08a908c00852b279b984016354d91f001b169@62.171.159.163:23656,e28444d2b661e23f95e6bedb7fd0a2cd533856ac@65.109.15.186:36656,da24e06a43dd60707b31217a770be115731bb557@165.227.165.197:23656,782cb61f5f416cf637ef71d0d80d5cbda7846a94@135.181.151.107:26656,4b5884ccf4ab395a8031fabc3db74b1de3300195@194.180.176.180:23656,428e2f8759cfecc7736ea72e87639299644f4c16@75.119.146.181:23656,80d97c99bc02b84676b233d96f07bbba5924dd68@185.144.99.67:26656,23bcc603002fc8c920a7dcfa94e9541cb4e7742a@185.144.99.99:26656,3b44ce349148ff19f9d293d0e51235f64cab0ba3@159.223.217.100:23656,82a2143823ab70c7500bf08d84149b7327cb963e@34.171.149.140:23656,4dd0b3b158913aadb6ce856ec5b26337e3855a18@135.181.248.69:36656,abc7bd2333917a09c46561f06bc2698653a2484b@159.69.149.203:23656,6edc1c3c488d2f5a247f02af690588d3b247cc8f@164.92.157.65:23656,5b04d13bd3f11048cf2afecce88a1f258b3ab945@20.100.172.91:23656,13cef349f7b4fd8c98bf515371537417e352c596@65.21.144.88:23656,d63ba5bb061cd530204f0d87a7fd8bf739b05883@142.93.105.5:23656,859bfe5ba5858dafaa66b11d5ed430039f1931f2@5.199.133.114:23656,357458b9de21f2352060498ba1409a9f047f7f74@137.184.111.176:23656,f363b5401a9891421a86caf1d248782868b2a05a@64.227.67.65:23656,76a9c7a56981d0737accafdf7c1f2bf9dd2b91b8@20.84.76.87:23656,0c7556ab80727b4f209ac42af388e7c74d74921f@45.67.216.77:23656,8fe9168a1fdaee7744f5b8c1f10a1caa9900358f@164.92.174.23:23656,fb75fd49045c2b22c1db23ae853d8702aee388bf@209.126.9.103:23656,90a1c3eda41010393729af7cb068baa254a0f8f9@198.199.82.157:23656,0053f851eaa20843b245fd21a3bc1f02578f6281@35.203.123.75:23656,a2fc44b2825182422fba60931a9e91925a293ded@209.97.134.97:23656,44133808f0aa279ac48873f218db6f624667646f@157.90.179.182:26616,4225449b63e692650f16c0fb897a9d4f3b7b938b@167.235.73.132:23658,2b43910f82d55dc1ad2744658d4a0e2bf4b21f98@95.216.220.64:23658,789ae52e1ef1047a73a8f64b8eb3fc2bb54f8ed0@65.21.254.161:23658,b01f4bf8d372a47e727d604dadd13ffbd2bfa8ce@95.216.210.104:23658,78a0aa68be8a944637e70aa655fbc9ab46192ecf@65.108.220.117:23658,a573c23191a5114b7c13c555227b9cd5dcc12fb4@65.108.249.29:23658,033f317d879eecd733c9af2a6a2159cb4ea24150@78.47.217.149:23658,830aab1ae690b406bbec93cf0e01ca7bba5870ba@78.47.124.253:23658,7a913c33c7a16ee160a403c170d6d1f34d97a4f0@78.47.105.73:23658,f86ab676050b8582423f835c8d14eebd648e1de4@78.47.131.222:23658,e9c098097e98265f39c37a7cb95708feb7a39186@65.21.144.88:23658,5f5ca9ac05878e93e65c48ac08311405a8ef5b2a@195.201.18.93:23658,b1070455d95c7a8b874f77201e072507f5b982e5@65.108.250.219:23658,bcb8420c5a3c67a9c4a4803c2a1d02d32f09eb8d@20.224.44.231:23656,9db59d9a6dd10ea2d5247432e0a371bbb97811ba@65.108.80.183:23656,245d766d00e6f7d1afdefc6e09d7be4314e8cc71@65.108.206.56:23656,1a5adae36c507e2f9354fcd2a44a483d3638ddf0@135.181.91.177:23656,1fb0892581455b14990238b09e4ee928c9ad57be@38.242.225.140:23656,3dcf50b01e256bee62aae9973a6b14fd59bb977f@188.166.104.216:23656,79b01f5a4e944cef4904661bb8a0648d5d27af61@137.184.121.240:26656,,0694fd03b4b610e8c4f6aefc24f0eef77d1007c5@46.101.31.77:23656,52b066fd12ac85139946e845cf487937b1e5fa69@178.18.243.74:23656,a5cc8033ff9ffea26c1f90c568966dae9ee47f03@194.5.152.166:23656,b134484bf7ad247a223570872bf10fe5f92c1dac@95.111.232.59:23656"
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

sleep 1

sudo apt update
sudo apt install lz4 -y

sleep 1

sudo systemctl stop gaiad
gaiad tendermint unsafe-reset-all --home $HOME/.gaiad --keep-addr-book

sleep 1

cd $HOME/.gaiad
rm -rf data 

sleep 1

URL="https://snapshot.testnet.run/testnet/gaia/GAIA_2022-08-27.tar"
wget -O - $URL | tar -xvf - -C $HOME/.gaia/data

sleep 1

sudo systemctl restart gaiad

sleep 1

echo '=============== kurulum bitti . www.nodeswizard.com ==================='
echo -e 'logları kontrol et: \e[1m\e[32mjournalctl -u gaiad -f -o cat\e[0m'
echo -e "senkarizasyon kontrol: \e[1m\e[32mcurl -s localhost:${GAIA_PORT}657/status | jq .result.sync_info\e[0m"
