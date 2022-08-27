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
STRIDE_PORT=16
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export STRIDE_CHAIN_ID=STRIDE-TESTNET-4" >> $HOME/.bash_profile
echo "export STRIDE_PORT=${STRIDE_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo -e "Your node name: \e[1m\e[32m$NODENAME\e[0m"
echo -e "Your wallet name: \e[1m\e[32m$WALLET\e[0m"
echo -e "Your chain name: \e[1m\e[32m$STRIDE_CHAIN_ID\e[0m"
echo -e "Your port: \e[1m\e[32m$STRIDE_PORT\e[0m"
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
git clone https://github.com/Stride-Labs/stride.git
cd stride
git checkout cf4e7f2d4ffe2002997428dbb1c530614b85df1b
make build
sudo cp $HOME/stride/build/strided /usr/local/bin

# config
strided config chain-id $STRIDE_CHAIN_ID
strided config keyring-backend test
strided config node tcp://localhost:${STRIDE_PORT}657

# init
strided init $NODENAME --chain-id $STRIDE_CHAIN_ID

# download genesis and addrbook
wget -qO $HOME/.stride/config/genesis.json "https://raw.githubusercontent.com/Stride-Labs/testnet/main/poolparty/genesis.json"

# set peers and seeds
SEEDS="d2ec8f968e7977311965c1dbef21647369327a29@seedv2.poolparty.stridenet.co:26656"
PEERS="17b24705533d633cb3501233a18912ae6cc36a41@stride-testnet.nodejumper.io:28656,a363d7ad123635a199dcc69df93e5d0d0dbf53b6@195.68.159.62:26656,515ab0625988500cb3de25df83185ea7e0b7cea1@151.236.219.219:26656,93252da657469786a9591c64c5de2155b35ecbbf@65.21.5.246:26656,07d5724ab2c5d60af14747f4ac2b8582f9071f99@176.124.218.120:26656,4c0118115b8c8e943d4e14664569021ad842beea@188.166.93.156:16656,57fea82e70f8ffef72a3d09021796a52c43685d8@65.108.206.56:16656,fe68ef3638b559e396ca44953166dd0502d071bb@149.102.147.147:16656,dce4eb70fad0a1d8206c179a5d3efa508c37d9e3@65.108.129.29:16656,bfe9b1e039e6162a6a5ad5bdf8c34958a15725cf@134.209.92.95:16656,0c6ec29b87700618189daf7c3af5761ae528c4d6@5.189.170.154:16656,ce6ec56138b04c60229affb4bbe965e7d25ff02f@38.242.247.26:16656,82099b8b2b7702c4ce7f547a457f53411f4ee981@38.242.137.59:16656,2e836cda9dad7caf630fdd168f47e4b6c964f41f@178.62.194.83:16656,73ae770c1f82bc7dbafaafe715da16ab9baa3547@45.151.122.100:16656,41a442c9b5e4582a261dbbefd756ae5009a359bc@185.211.5.242:26656,12090dadc2c6b1b90a4a2f77259f107a36c17242@65.108.249.29:16656,053de449c1ef09088e05dd16c98f3b99b18d04b3@194.163.146.38:16657,6efff75a9ea3c28d36a4ad0bbc2b9140c057bbcf@167.71.137.27:26656,8ff255af7f4d13429af028184a917093cddb92ff@185.216.75.46:16656,71b92d96d2f00f835ff78ed90d63f9d4de60d262@75.119.135.34:16656,b8e881456f88b0ed059a7af1852e7dbd202cdc55@173.249.50.115:16656,c5b4d1efcb269a00606a370732f344a8c1789fba@185.16.38.226:26656,bd68db80c9ae099c1a9180bd2fc7dd6d43bb602b@5.161.106.96:16656,bffc08b2767837906882f19219eed7765dd994c8@62.171.166.5:26656,da771854ddfbb73aac294fbbd11346892d71c75d@144.91.83.66:26656,4a66ef3e2b0c203a985a2ca6a5fe48af7ea32f24@178.62.113.115:16656,75a31f6c7e6626a667470e5345bdb98a095b8474@173.249.33.184:26656,6a95bbea4fe9b5538c98aaa90fd42b538e89a60e@185.205.246.68:26656,379ba266e62763442c9a547b419ff271905228ab@38.242.159.179:26656,0da6d92f64d4d9f4060bcfad95075eaf98cf937a@194.163.152.85:16656,1124d9184720edefe987290bbd6f291572be27f2@137.184.137.28:26656,416e6fbb42557375bee9514b58adbcc68783be14@135.125.132.186:26656,d0933ca5650052be63692caa061bea96cdf22dec@38.242.214.172:26656,e62691df80e834336f390341c637e5b0f5b3a881@173.249.49.238:16656,d017aedc2e3965b1d61633bcb34a51d351d63fcf@86.48.2.124:16656,689a21445666355e7f868dc89d0afcab64c640c1@64.225.107.246:16656,a24469b6463b26103d4a00758beac216ec087f0b@135.181.248.69:26656,da06f970a9028dc37a4aabd1ec125d81ec176be7@178.62.78.147:26656,e92dbf725e59ad37a8e2b95d0addbd2a6bee8a51@86.48.0.161:26656,eb598bb4da19a61b2f050cb6c50fe0d511d161bd@167.99.83.10:16656,3db3f7e297cf924f08b251b9d0958a7fb1a9cdbe@95.216.220.64:16656,f6169fde8afbcefbe040c114f643a2aaa901e41b@43.130.233.32:26656,24f0fd1110885a8b962000fb1c91224e1ecd61f2@161.97.145.238:16656,d3bf039f61dce7b2c58d71f163f6563cb793d965@194.163.175.30:16656,4ca5697db5fa49f5f74f63ae3af4ce7c23ce1775@149.102.149.20:26656,806098a55f676f8cc591e661d854e1e20c862538@45.151.123.97:16656,e00fd454f7771eef4943b4b2abd887ead3259b19@135.181.82.56:26656,34e943bbbe85feea55bb1e577baf2984f7d96ef1@135.181.81.224:16656,a860765406b9d9a966d3311e2b5b61aa17708dc1@135.125.163.63:24666,77b976357375fd7fe3a468036d1105ade2d0d062@165.227.236.94:26656,453a1961a67b63da3b3ea8e9f11de737d574813c@144.126.135.2:26656,7fd514717ac90ef7431de08b4d013d62c800869b@43.134.187.12:26656,535e69d2c7beb7305e6ce7655169990616066e0b@38.242.254.104:16656,90bc306ca20201a99104809480fb49c1eaebcb53@65.108.220.50:16656,93714dfd4d39424925b43cb889db2aade2cc7e3b@194.180.176.175:16656,7dc60b273539aa4e7ddf6220d09f3a8fe7e84b86@38.242.210.93:16656,3e955fb0a5bedd21b21987f1123727d0dce513e0@144.91.76.186:26656,e9bad75da2e743d4506475a3af44c46251075b7a@149.102.142.82:26656,d02baf8153bc38a7d405cbe9ef08bb0d71d92ac4@46.101.18.220:16656,ae80e153ed3970c86397ad186efc9b8ec610a75b@20.106.132.125:16656,ce37fa1884e007346be4e670101a0dc77376ab5c@38.242.219.233:16656,56a6be165d4e0698dad984564b1074b2e5e2ea97@65.21.225.58:26656,be4648e93aa96133db1abb4ee65ba37f53858c80@65.108.240.23:26656,23573e96a23292e97ce42a03260799f2a20415b6@88.198.39.43:26736,bf6ca3e0ba11bb00545f182c674e14d4e0fc9a47@194.147.58.195:26656,95fccd0c2e5eecdf6e51538a71d5fb5287fde594@95.217.222.44:16656,d487d1fd4eca98974475378a95f2f1fef2ed7e84@217.79.178.14:16656,4420710617a1cc3ecfe091c2ed1a40dfac71564c@195.201.243.40:26656,f96fb1eac5ba57d226b83814aefe7c2a08639e25@135.181.89.127:26656,a68bb3b6b4eaa3d54766160dd6751355e9287199@45.87.104.44:26656,1705ea4aa37b90571155784400742fffa75a7250@91.223.3.163:26656,965fcfeed138dd5b48bfb00af9760ae9b7f472d1@149.102.133.151:16656,ce72b1feb5b938af9baf2ac73795167c8b47b9ef@192.145.37.211:26656,5edbb0261eefe200495ea5146c8e2b117896a92d@68.183.64.98:26656,bfe5fd6498cde0b4a5326eb2af5000a055156251@49.12.98.118:12656,b8def474e8d3b825d284784df86e4c383ce69e00@38.242.135.234:16656,ab825ed5791f506fe3e99856ca599bd8c9cc0d3b@20.234.64.217:16656,f11b08f033b79699d3727cc4e7cf11923c3fc0a8@195.201.106.36:22656,f2334364a4a5043356393b8badb1e95a27d29d6c@65.109.18.179:28656,fbeb1e725834e674b807644eb798c86cfa9b3df1@46.8.19.208:26656,1a7c27b625b2ee6fb49013184fb71bfaf6fccf95@167.86.87.74:16656,8e094902fa1ae81b3d4869e4f902869bcec332af@149.102.138.244:16656,cf1867d88adb5d365571a0bc0d63e0dfb929437d@95.111.225.30:26656,d5a52e246601ea09f4543e43aab65fea113ce080@65.108.101.50:60556,bbf17b3eacdbd75f4ce5e0437405879c4ddec43c@65.108.252.239:26656,297210c536fc4a03e9ad0f8e983c8b947a989e13@65.21.88.78:36656,3b9620752a1def9968e92e37490c558ffcc2cf85@185.209.31.7:16656,6b482576c26082a44c124bf9f5b1e4777840ee26@134.122.98.242:26656,f4d319084b81d66968403a858b100c2e19c8ac77@75.119.151.202:16656,4581e3169cf177553229a79b1b5ffa4d3ab49163@135.181.89.29:16656,ca2f7d32785b8bd7753d47f4c74933d13d319a0a@78.47.131.222:16656,5cbaad7dfdcf85f55a16992b7ca24ff349d69c91@45.8.145.59:26656,1e63ab31d933f15e08a89687cca6a948de575b1d@75.119.157.119:16656,02aeadb134fac2ec67d7a8c33bf7ad6b88e03658@149.102.141.197:26656,0158cb94bd0c1b9e6801394eee7c001a85b0827e@176.57.184.184:16656,acf2f5f56a46ead13ce169c31cbde2b41649569e@185.234.69.254:26656,3c9acfaf3586a4516440c2d46aa95fffa0f0a8fc@65.108.235.151:16656,b3840812e43733e15ed72146d05fa2d5cf2880d0@62.171.161.25:16656,fe04b80912d947e2e1acd7c2ff628c494bb07b43@137.184.207.237:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.stride/config/config.toml

# set custom ports
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${STRIDE_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${STRIDE_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${STRIDE_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${STRIDE_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${STRIDE_PORT}660\"%" $HOME/.stride/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${STRIDE_PORT}317\"%; s%^address = \":8080\"%address = \":${STRIDE_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${STRIDE_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${STRIDE_PORT}091\"%" $HOME/.stride/config/app.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.stride/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.stride/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.stride/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.stride/config/app.toml

# set minimum gas price and timeout commit
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0ustrd\"/" $HOME/.stride/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.stride/config/config.toml

# reset
strided tendermint unsafe-reset-all --home $HOME/.stride

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# create service
sudo tee /etc/systemd/system/strided.service > /dev/null <<EOF
[Unit]
Description=stride
After=network-online.target

[Service]
User=$USER
ExecStart=$(which strided) start --home $HOME/.stride
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
sudo systemctl enable strided
sudo systemctl restart strided

sleep 1

sudo systemctl stop strided

sleep 1

strided tendermint unsafe-reset-all --home $HOME/.stride --keep-addr-book

sleep 1

sudo apt update

sleep 1

sudo apt install lz4 -y

sleep 1

cd $HOME/.stride
rm -rf data 

sleep 2

SNAP_NAME=$(curl -s https://snapshots2-testnet.nodejumper.io/stride-testnet/ | egrep -o ">STRIDE-TESTNET-4.*\.tar.lz4" | tr -d ">")
curl https://snapshots2-testnet.nodejumper.io/stride-testnet/${SNAP_NAME} | lz4 -dc - | tar -xf -

sleep 1

sudo systemctl restart strided

sleep 1

sudo systemctl stop strided

sleep 1

cd $HOME && rm -rf stride

sleep 1

git clone https://github.com/Stride-Labs/stride.git && cd stride

sleep 1

git checkout 90859d68d39b53333c303809ee0765add2e59dab

sleep 1

make build

sleep 1

sudo mv build/strided $(which strided)

sleep 1

sudo systemctl restart strided

sleep 1

echo '=============== KURULUM BITTI www.nodeswizard.com ==================='
echo -e 'Loglari kontrol et: \e[1m\e[32mjournalctl -u strided -f -o cat\e[0m'
echo -e "senkrazasyon kontrol: \e[1m\e[32mcurl -s localhost:${STRIDE_PORT}657/status | jq .result.sync_info\e[0m"
