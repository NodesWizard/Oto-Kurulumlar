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
PEERS="17b24705533d633cb3501233a18912ae6cc36a41@stride-testnet.nodejumper.io:28656,a95983fa2110e1f95529d0a5cc9e6b40e10f9ef5@194.163.136.221:26656,e0d34df5085e3f1617f3a4683a54e4f1cfa2162d@137.184.16.89:16656,b3840812e43733e15ed72146d05fa2d5cf2880d0@62.171.161.25:16656,78010533f26466232b84f61d2b3d5247aa137697@176.124.212.172:16656,9a2e21e87b3b7cd7fbedb277210b768636ff0453@65.21.248.203:16656,563cb05ab5f0aaa192d6f0ff619f965146749880@95.214.53.37:26658,ce3554e18c9ef5a40557d9f7797bbb3dae57a91f@38.242.227.89:26656,f8bc64b4627b6c047e0083f567c50cfe787d6eed@167.71.13.19:26656,a370cdb542625777901891c9fe14d2a3777dbda3@144.76.99.153:16656,d15674410aede73346cf55a4d19a4e2451103216@144.91.80.197:26656,de8c97b863fd56556536aedfb6a9e3d179e4a98a@207.180.205.58:26656,ee24b8403edaf3cd67f4e4fce3cbd0caaf5ee7c6@67.205.166.98:26656,c3bf228ec5880bf5286c8be207047a0dcd009176@38.242.134.197:26656,967284b22cdf84262a9fe00228e29e274162c54a@38.242.221.236:16656,c4b9e5678a1f0cd70096382068419a2361e3858e@185.169.252.86:26656,adc0c285e348e1767f72198619f9aecd4f65910c@139.59.181.208:16656,a22bcbf1d2071f7112cc3b93a6865f41832c3923@188.234.160.67:16656,5037c7262d108b143cdc71d123618d1c9ce682fc@34.71.219.19:16656,ab825ed5791f506fe3e99856ca599bd8c9cc0d3b@20.234.64.217:16656,d7bb29b51b258a235b764ee41af845963e16c833@65.21.147.185:26656,4a66ef3e2b0c203a985a2ca6a5fe48af7ea32f24@178.62.113.115:16656,6164eee31c460fa6508dee20eaefecc1b4dfbf42@185.237.96.92:26656,41a442c9b5e4582a261dbbefd756ae5009a359bc@185.211.5.242:26656,fe68ef3638b559e396ca44953166dd0502d071bb@149.102.147.147:16656,5ca025a582c3221e401fa2550a9756e853a06876@139.59.150.17:26656,28a907ae9924c7a3bb5433c5b0e99f686d6e9c56@178.62.249.31:26656,0f8cd228345aadb039c707230364a94db9bf5280@167.99.33.168:16656,cf5cfb2a8c8a1d03dd2fcf14751247bced00352e@185.246.65.112:26656,015964bdacffb28109d506ca6ab607264d85f077@86.48.0.147:16656,8d534ccd28f9b09630e7e5414ace497604f0ad76@213.136.85.210:26656,33944648d37aa27d6aa580db6acee6fc1e1ee7ff@43.159.56.16:26656,53fdc1225c2aca3c6aac9e308fa5c1b5a623fa69@143.198.176.82:26656,6bb055f45e647cfef73a76292cf41f9d63e885c1@194.163.184.84:16656,87afb8bc595025e38115fcac8e0910f0262e36d9@188.166.53.73:44656,74a84ef1636b73fc22fc88fe7445ba98ef703cf2@45.151.123.141:26656,9863f91f0d0767419450c5a6cdf19e238cebbcc7@209.97.191.128:16656,009675e502e242b27eb519203ffad48b3bf5ca45@144.91.82.32:26683,a406069eae8a67ba78b2226c4b91caf04f161eff@164.68.99.180:26656,df31f12087bac27d4460c2865aaa0ca8fa8cd756@46.101.210.50:16656,3bae9347b7a6c148fa70cbd70b42a643d38e024d@95.217.11.20:36656,0f9de63e13be09f9c41cea91fc88e1b7fa6c1f61@65.108.225.70:26656,777823448fde8e86955de58c770ed7508ccad94a@194.163.152.25:26656,9a6daa72a4d462ef0c6183efad7134678d09b0cb@65.21.245.112:16656,7dc60b273539aa4e7ddf6220d09f3a8fe7e84b86@38.242.210.93:16656,09c2acbd6be4e423a59b83c7fe07b90d7c0e89c1@178.128.198.140:26656,7f9692a54a713b0c4761a6792e94be3f7d687aab@165.227.162.24:16656,4c0118115b8c8e943d4e14664569021ad842beea@188.166.93.156:16656,e4435b484569f591092c4cb93e54df49cbabbf09@94.103.94.53:26656,7f31049c36f99efacaf5df7ac2771b18fa2cba14@88.99.105.36:26656,4fcaff4aa3366afd2c6580abf0c2371702f04d03@138.201.59.106:26656,2ee5b9b2cd5fb04ca8772643d95d3f33a858a26e@65.109.27.70:16656,d487d1fd4eca98974475378a95f2f1fef2ed7e84@217.79.178.14:16656,c423eab10237b230822d16ab9f154f74111c3b1b@209.145.56.78:16656,bffc08b2767837906882f19219eed7765dd994c8@62.171.166.5:26656,df1329d3997aff92f46c1672fa526aaec158ecec@185.197.75.47:16656,651c310ff71bcfd1517d08e072237795b27fa8e4@38.242.156.243:26656,e28ccdf2ba15eeb130d48c1eba5bfd87a28d4e44@136.243.54.229:26656,2e63b7d855ac7ab5a1846bbebdc62580d904ac76@38.242.159.20:16656,b8d5aba3a9f2c7407b7b97b057f939203ae58d89@172.105.152.248:26656,43618c3774008aca14fc87e1c7ff4d0a402ff705@178.18.241.243:26656,4f2f9eaeb3fe112aa4f388e6ebbffc0cf2a20c33@185.209.228.187:26656,156e080c709b79c4435cd0a420b84ce6dad5eeec@65.108.255.84:26656,58d9720b10016beeb62858de2c2863c6d085f6ae@194.163.129.79:26656,a3480c09b4c504c540024e8bbe9914c1bf08a088@135.181.255.148:16656,5bad0816154a26cd0a3830146f343aae7463b0bf@51.89.116.237:26656,c0b15c6853ce8a20b6a38ae204a4d79e62e10bc2@188.166.54.148:26656,5229a08b95febdba240a9965e9ed66597425f549@144.91.78.102:16656,874d916f3734ca5f38d7c22ee0f1caabdbc54e85@138.68.90.84:16656,5b24ff7fd1303cee8683678e3dfc2be839ce3c50@167.99.58.79:26656,ce72b1feb5b938af9baf2ac73795167c8b47b9ef@192.145.37.211:26656,0451f89d285424752fe6decf8f26e7468492fb9a@135.181.98.172:16656,a2584d6fcd682cf656f67068b929256d2db4d01a@194.163.174.198:26656,7c12e71eb64fd909900ba564cc5f4a64854a6cd0@38.242.242.196:26656,32027788fab6e87426bcd7df3d88e6297c933817@20.82.163.109:16656,984149c68ae0ed80cd6eba19f2292d5f24aca899@38.242.132.195:16656,7fa1b47ef2926a91537208d31ffaf2bff710f75a@38.242.234.98:16656,c413d6f65e3726ca56c2f3c7882ed6722fa60565@207.154.226.22:26656,e9d90af81c2898814e9b6ae7a6ce998e2e4d6dcc@161.35.98.9:26656,34e943bbbe85feea55bb1e577baf2984f7d96ef1@135.181.81.224:16656,a62854ec220bde2c2d4d6fcb341b7db5402fcfa5@149.102.159.178:16656,299a9fb1cfe13d9e0152e58f016f19ea43ded32b@95.216.217.3:26656,cbc51881c583108bf2d4c12576c7538ab8b22ce2@62.171.128.175:26656,6835f89054bc8b3a84485460bde060c0a72fa6ed@185.208.206.220:16656,7f7970c0ecb8385bef5e5873181e30802c9d7be3@146.190.29.185:26656,8dd519ed49398f18d54d26680adddb7aa4af1730@62.171.136.191:16656,991895494391c3a9179f840b4d69066c87692389@217.73.80.47:26656,4509dc2c27323042c055035e8ccf837d99cb62d0@95.216.208.101:16656,a4d92b841e8e5ead4a69ed01c9301c0daf8b6cf6@45.88.104.34:26656,5d37b606c2f2f160b8e4e22d448eb10bd8ecbb58@95.217.84.248:16656,fef5a04c72fb967e4271d0d73cfa8a87234b0dd3@95.217.155.89:16656,a860765406b9d9a966d3311e2b5b61aa17708dc1@135.125.163.63:24666,98913af5e6611e820615ad7631f13471373a5ec2@85.190.254.136:26656,e62691df80e834336f390341c637e5b0f5b3a881@173.249.49.238:16656,dcdc9b84cd80a2aa6f5fd629163af0a773a0c80c@167.86.73.195:16656,f094bfb90b92b813987a8b9099a702b22e789b0d@38.242.246.76:26656,fd9a45b43c0462d7792a80d52588cbd048990ea6@185.217.126.187:16656,076161ab1d7eb3248ea96c27b3f217d32e1c7829@193.46.243.171:26656,9270bf903f88f59ad698ed168e34fa7e65755202@194.60.87.58:26656,aab7adcd3f3eaa564a5ced76482889b1f5f5e059@195.201.126.137:16656"
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
