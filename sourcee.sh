#!/bin/bash

echo -e "\033[0;35m"
echo "  _   _  ____  _____  ______  _______          _______ ______         _____  _____    ";
echo " | \ | |/ __ \|  __ \|  ____|/ ____\ \        / /_   _|___  /   /\   |  __ \|  __ \   ";
echo " |  \| | |  | | |  | | |__  | (___  \ \  /\  / /  | |    / /   /  \  | |__) | |  | |  ";
echo " | |\  | |__| | |__| | |____ ____) |  \  /\  /   _| |_ / /__ / ____ \| | \ \| |__| |  ";
echo " |_| \_|\____/|_____/|______|_____/    \/  \/   |_____/_____/_/    \_\_|  \_\_____/   ";
echo -e "\e[0m"                                   


sleep 2

# DEGISKENLER
SRC_WALLET=wallet
SRC=sourced
SRC_ID=sourcechain-testnet
SRC_PORT=39
SRC_FOLDER=.source
SRC_FOLDER2=source
SRC_VER=
SRC_REPO=https://github.com/Source-Protocol-Cosmos/source.git
SRC_GENESIS=https://raw.githubusercontent.com/Source-Protocol-Cosmos/testnets/master/sourcechain-testnet/genesis.json
SRC_ADDRBOOK=https://raw.githubusercontent.com/StakeTake/guidecosmos/main/source/sourcechain-testnet/addrbook.json
SRC_MIN_GAS=0
SRC_DENOM=usource
SRC_SEEDS=6ca675f9d949d5c9afc8849adf7b39bc7fccf74f@164.92.98.17:26656
SRC_PEERS=9d16b552697cdce3c8b4f23de53708533d99bc59@165.232.144.133:26656,d565dd0cb92fa4b830662eb8babe1dcdc340c321@44.234.26.62:26656,2dbc3e6d52e5eb9357aec5cf493718f6078ffaad@144.76.224.246:36656

sleep 1

echo "export SRC_WALLET=${SRC_WALLET}" >> $HOME/.bash_profile
echo "export SRC=${SRC}" >> $HOME/.bash_profile
echo "export SRC_ID=${SRC_ID}" >> $HOME/.bash_profile
echo "export SRC_PORT=${SRC_PORT}" >> $HOME/.bash_profile
echo "export SRC_FOLDER=${SRC_FOLDER}" >> $HOME/.bash_profile
echo "export SRC_FOLDER2=${SRC_FOLDER2}" >> $HOME/.bash_profile
echo "export SRC_VER=${SRC_VER}" >> $HOME/.bash_profile
echo "export SRC_REPO=${SRC_REPO}" >> $HOME/.bash_profile
echo "export SRC_GENESIS=${SRC_GENESIS}" >> $HOME/.bash_profile
echo "export SRC_PEERS=${SRC_PEERS}" >> $HOME/.bash_profile
echo "export SRC_SEED=${SRC_SEED}" >> $HOME/.bash_profile
echo "export SRC_MIN_GAS=${SRC_MIN_GAS}" >> $HOME/.bash_profile
echo "export SRC_DENOM=${SRC_DENOM}" >> $HOME/.bash_profile
source $HOME/.bash_profile

sleep 1

if [ ! $SRC_NODENAME ]; then
	read -p "NODE ISMI YAZINIZ: " SRC_NODENAME
	echo 'export SRC_NODENAME='$SRC_NODENAME >> $HOME/.bash_profile
fi

echo -e "NODE ISMINIZ: \e[1m\e[32m$SRC_NODENAME\e[0m"
echo -e "CUZDAN ISMINIZ: \e[1m\e[32m$SRC_WALLET\e[0m"
echo -e "CHAIN ISMI: \e[1m\e[32m$SRC_ID\e[0m"
echo -e "PORT NUMARANIZ: \e[1m\e[32m$SRC_PORT\e[0m"
echo '================================================='

sleep 2


# GUNCELLEMELER
echo -e "\e[1m\e[32m1. GUNCELLEMELER YUKLENIYOR... \e[0m" && sleep 1
sudo apt update && sudo apt upgrade -y


# GEREKLI PAKETLER
echo -e "\e[1m\e[32m2. GEREKLILIKLER YUKLENIYOR... \e[0m" && sleep 1
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y

# GO KURULUMU 
echo -e "\e[1m\e[32m1. GO KURULUYOR... \e[0m" && sleep 1
ver="1.18.2"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version

sleep 1

# KUTUPHANE KURULUMU
echo -e "\e[1m\e[32m1. REPO YUKLENIYOR... \e[0m" && sleep 1
sudo curl https://get.ignite.com/cli! | sudo bash
git clone -b testnet $SRC_REPO
cd ~/$SRC_FOLDER2
ignite chain build

sleep 1

# KONFIGURASYON
echo -e "\e[1m\e[32m1. KONFIGURASYONLAR AYARLANIYOR... \e[0m" && sleep 1
$SRC config chain-id $SRC_ID
$SRC config keyring-backend file
$SRC init $SRC_NODENAME --chain-id $SRC_ID

# ADDRBOOK ve GENESIS
wget $SRC_GENESIS -O $HOME/$SRC_FOLDER/config/genesis.json
wget $SRC_ADDRBOOK -O $HOME/$SRC_FOLDER/config/addrbook.json

# EŞLER VE TOHUMLAR 
SEEDS="$SRC_SEEDS"
PEERS="$SRC_PEERS"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/$SRC_FOLDER/config/config.toml

sleep 1


# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$SRC_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$SRC_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$SRC_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$SRC_FOLDER/config/app.toml


# ÖZELLEŞTİRİLMİŞ PORTLAR 
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${SRC_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${SRC_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${SRC_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${SRC_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${SRC_PORT}660\"%" $HOME/$SRC_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${SRC_PORT}317\"%; s%^address = \":8080\"%address = \":${SRC_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${SRC_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${SRC_PORT}091\"%" $HOME/$SRC_FOLDER/config/app.toml
sed -i.bak -e "s%^node = \"tcp://localhost:26657\"%node = \"tcp://localhost:${SRC_PORT}657\"%" $HOME/$SRC_FOLDER/config/client.toml

# PROMETHEUS AKTIVASYON 
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/$SRC_FOLDER/config/config.toml

# MINIMUM GAS AYARI 
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.00125$SRC_DENOM\"/" $HOME/$SRC_FOLDER/config/app.toml

# INDEXER AYARI 
indexer="null" && \
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/$SRC_FOLDER/config/config.toml

# RESET 
$SRC tendermint unsafe-reset-all --home $HOME/$SRC_FOLDER

echo -e "\e[1m\e[32m4. SERVIS BASLATILIYOR... \e[0m" && sleep 1
# create service
sudo tee /etc/systemd/system/$SRC.service > /dev/null <<EOF
[Unit]
Description=$SRC
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which $SRC) start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF


# SERVISLERI BASLAT 
sudo systemctl daemon-reload
sudo systemctl enable $SRC
sudo systemctl restart $SRC

sleep 3

# SCREENSHOT YUKLENIYOR
systemctl stop sourced

sleep 2

sudo systemctl stop sourced
rm -rf $HOME/.source/data/
mkdir $HOME/.source/data/

sleep 2

cd $HOME
wget http://116.202.236.115:8000/sourcedata.tar.gz

sleep 2

tar -C $HOME/ -zxvf sourcedata.tar.gz --strip-components 1

sleep 2

wget -O $HOME/.source/data/priv_validator_state.json "https://raw.githubusercontent.com/obajay/StateSync-snapshots/main/priv_validator_state.json"
cd && cat .source/data/priv_validator_state.json

sleep 2

cd $HOME
rm sourcedata.tar.gz

sleep 2

sudo systemctl daemon-reload 

sleep 1

sudo systemctl enable sourced 

sleep 1

sudo systemctl restart sourced

echo '=============== KURULUM TAMAM!  Nodeistin katkilariyla . www.nodeswizard.com ==================='
echo -e 'LOGLARI KONTROL ET: \e[1m\e[32mjournalctl -fu sourced -o cat\e[0m'
echo -e "SENKRONIZASYONU KONTROL ET: \e[1m\e[32mcurl -s localhost:${SRC_PORT}657/status | jq .result.sync_info\e[0m"

source $HOME/.bash_profile
