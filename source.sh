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
SRC_PEERS=ff52cead20cf60f6cc02757152b681af50869d0d@116.203.191.53:26656,3e74a88b59865a2d9f2ec580a37e8b406e96d3fc@173.249.5.146:26656,c4f75677b1b9411da8449f86fe9f070fa9382c22@144.91.83.54:26656,c675b39ca0e47a95c4d37c8a98a14ac93b46bad6@143.110.184.196:26656,383a0684aadfe507e097c36b34d6243da59d9ed5@207.180.232.91:26656,d9aac0b2753ef46858d03f8497431b99740e8abe@5.161.147.146:26656,07b6fa3e91b7bed1c47a46648089e8041641f050@178.18.240.148:26656,a7ce1512d39d9c9b1293e8b55b59d18f5313b536@116.202.236.115:20056,d57c4825b2823f94f87b7cbcc4748420edfcd6df@5.161.77.35:26656,7545bbb24348add3b0f373e62d30ea796637ceec@95.216.223.200:26656,9772d203f7311f74bde72da2f02c2a5fe142bb17@35.246.76.106:26656,3620fb4df9be7e697f451f6331eb58eefff04e95@176.124.205.215:26656,be875169367c1b74fd2fddf12f1047a3661de1f5@173.249.38.51:26656,c293787dd1aeede1e1716196db4abb30d171710e@38.242.220.245:26656,84861b505feb5fdc7d44bd5d7986862612999323@185.211.6.193:26656,5ad861a88ba75ca074519d0f3d2eb51b671b0e28@137.184.216.128:39656,98172a02e52023fefd1e413efe744f56954fa129@164.215.102.44:36656,2c20351736d27e50952695801a4d77122ead307f@62.171.180.83:26656,7660502e4d981eae2c470fbd3918a2a95693ba42@161.97.166.136:26656,5ffbb9a8a9a47ebffc2cd1241380281bf944572e@188.34.195.244:26656,9da8183f07a7b33dd60fc01156ae8136041cef30@45.10.154.138:26656,7143126daf3c0983745a0b10b83c8e794c4fb2fc@65.108.126.46:33656,ba8620d21a266cefc7c14fbc70cb070efabb9920@65.21.227.78:26656,1bc2fa179a4df7f51b6fa27288454d0452e23442@62.171.144.222:39656,b02e2bd359623aeee2d4fad94d37af8b064508f6@167.235.224.141:26656,fc1a626fce5f5eb93ceaad9ce08aed7d3b921e93@86.48.1.141:39656,27a18ea5828b287b97f321276b4fa9827124a08c@95.111.240.154:26656,38140b9335b8891b6bec8c49198490cf80287c78@95.216.218.186:26656,c11b85deb59574812a7e6b9d6181df36bef15d2f@65.108.105.48:27656,14b16a1393ff0c95ce0a563e2225fc6e414edda7@159.65.94.178:39656,db8dd5489826d6edd3d0b2a6d22ed8fc01848858@185.252.235.214:26656,289928974e7153f4079208b4510519e1cb6063af@135.181.35.103:26656,dbba2131476082da8cdf6158931eeca72de6bfd3@62.171.181.47:26656,fae907ab505bfd41fc2499bd002fd58adc6fc68a@173.249.26.69:26656,af3e58ae818e96a4251cb8e2be045ae71339321d@104.248.113.206:39656,c61e2d79ef280ebc1f8a08d5db77f967fbf698bc@35.87.193.124:26656,b5cfe488ddf0b9e902716b2e18686f8b13c03182@62.171.181.251:26656,d0bf1f313c3fe5d9e890f7754950238493497211@62.171.178.217:26656,eced2139ee25834946b40a30a9469f247c9060a0@62.171.178.219:26656,c70ff8a8e73ae86dd05568e8fab67620352684f4@139.59.215.148:39656,4583a0374ff31ef55efe5f60de05928df394b922@65.108.241.219:36656,4ddc9760ace1966cd2906746a2bc00e907f0d8be@134.119.216.185:26656,341ae40165a5deea79d322a46c66f6a4dee8d666@20.119.99.79:26656,0c1512ee4b8c21bd75d840e13f62b2c3650cfd3d@62.171.150.241:26656,9f76461e09441d1c3616342138f28b49b757c20f@82.65.197.168:26656,c891aa4d39db8eec9a9f38e1a6582c02a16a4209@142.93.36.221:26656,c749b47c438842d9874b515de130dfb11431360f@147.182.211.27:26656,9d16b552697cdce3c8b4f23de53708533d99bc59@165.232.144.133:26656,67659acb9410728d60c565d325ad7e420181ed08@65.108.103.86:60856,cd6104da919fc8b0995ee5c67c8dce9ae98256bd@5.161.106.96:26656

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

sleep 1

# install the node as standard, but do not launch. Then we delete the .data directory and create an empty directory
sudo systemctl stop sourced
rm -rf $HOME/.source/data/
mkdir $HOME/.source/data/

# download archive
cd $HOME
wget http://116.202.236.115:8000/sourcedata.tar.gz

# unpack the archive
tar -C $HOME/ -zxvf sourcedata.tar.gz --strip-components 1
# !! IMPORTANT POINT. If the validator was created earlier. Need to reset priv_validator_state.json  !!
wget -O $HOME/.source/data/priv_validator_state.json "https://raw.githubusercontent.com/obajay/StateSync-snapshots/main/priv_validator_state.json"
cd && cat .source/data/priv_validator_state.json
{
  "height": "0",
  "round": 0,
  "step": 0
}

# after unpacking, run the node
# don't forget to delete the archive to save space
cd $HOME
rm sourcedata.tar.gz
# start the node
sudo systemctl restart sourced

echo '=============== KURULUM TAMAM!  Nodeistin katkilariyla . www.nodeswizard.com ==================='
echo -e 'LOGLARI KONTROL ET: \e[1m\e[32mjournalctl -fu sourced -o cat\e[0m'
echo -e "SENKRONIZASYONU KONTROL ET: \e[1m\e[32mcurl -s localhost:${SRC_PORT}657/status | jq .result.sync_info\e[0m"

source $HOME/.bash_profile
