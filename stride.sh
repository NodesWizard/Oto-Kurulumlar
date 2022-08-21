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
PEERS="17b24705533d633cb3501233a18912ae6cc36a41@stride-testnet.nodejumper.io:28656,98ec061c5ed3335a8573206f1ae1328d5cea42ee@83.136.251.210:26656,165f6cba877d71f0ad1c8ee6392beea35e04cb78@95.217.155.136:16656,390ff948ffbb9ad1793c3de91bf457750f3279b6@65.108.71.92:54356,aeabaf90afbe6321f2e8a33ddc5aebf2963f6efd@65.108.238.183:36656,328d459d21f82c759dda88b97ad56835c949d433@78.47.222.208:26639,4da4acaf27b264ebc35694bd24fc3ac629ed7177@207.180.246.42:26656,cd4cdb32f67dda2856b5d0acb9accb9966a9c16c@167.235.235.15:26656,23573e96a23292e97ce42a03260799f2a20415b6@88.198.39.43:26736,6c933f3ff3e529852e958f40c5d3c82296504e50@158.247.231.72:26656,4e4604ef850d45798dcd56ac2672da2342dbc175@45.147.199.190:26656,dd93bd24192d8d3151264424e44b0f213d2334dc@162.55.173.64:26656,d64cd93f3bb2e6a76b383bc089837d02076f6bc1@159.223.202.196:16656,d6e423fbd610dae4f0966cfed5b47165b4548582@45.91.168.197:26656,95ee745023b21aee6aa62c46352724b5f32240cd@161.97.91.70:16656,8deab2e38cd0a02bf2572340b6e082c59d856bae@2.59.156.145:26656,2a4e8999b465425287b6df9aeafa331c148ef7ac@38.242.132.75:16656,56dceaae59c6f272ef4957b246069af076347701@66.94.115.139:16656,57fea82e70f8ffef72a3d09021796a52c43685d8@65.108.206.56:16656,abb29071e552fb1cd8ecae886c50ac3471a170c3@164.68.125.90:26656,01806f822366b27c4f63502eeec689abedb20438@38.242.128.46:16656,31247edb9e6c238398d7f03b6ebac3ecdb39a19e@45.10.154.38:16656,89fc167903c6f8afd519cbc8cc1542ac6467f911@135.181.133.248:11656,cf1867d88adb5d365571a0bc0d63e0dfb929437d@95.111.225.30:26656,f8d187d02876bf40a24acbb1b4e08254adda40ad@92.100.157.81:26656,3983015b094e92c88b31250454c2093b39fe87c6@134.122.100.79:26656,866bb1cbc21bf1f1fd524717d536c1020bd26c45@49.12.237.93:26656,1a8a12acb9d68cfceef15826aa8183a755f038c1@159.65.81.42:26656,e8258197ad814ee250dbe921593da112e2486e16@34.171.149.140:16656,375bf00a82d55f02ec6e44974a6848a4e8af8016@149.102.146.46:26656,45380044a09852b7fac0c6bc4da625128118fd04@45.77.241.50:26656,3c8f6832372539b16c772a843458adc221aea960@45.155.207.219:26656,f0c7aaa7bcd159e4fe2775abc5968e3548af866d@34.135.153.30:16656,fcdda87767645df851c5405d9bb8601330a469c6@51.75.135.46:16656,e1ac927286e5b899aa2b93fbeb44677ec673e9f3@20.94.46.231:16656,e15c366f195d65885b595d678be18ad6f822b80f@185.252.235.89:16656,673cd2e8df973b8c10b1a460bd846e31b228373c@135.181.73.170:26757,9443ac82d9c5220e489e14be1335a871b9f6c552@178.62.122.192:26656,9988473a72d06d3eedec4eabafa677295015ce8e@65.108.137.92:26656,acc291258810e829db87a8babfa22cf82e217caa@141.147.7.113:26656,3aef99f334355ca0935855b72a5f8da23ded22a9@178.62.38.35:26656,e28ccdf2ba15eeb130d48c1eba5bfd87a28d4e44@136.243.54.229:26656,8acff5bc80a9d286721d540047c53f7ad0d54f2b@95.216.153.211:16656,59931fc8d6e2b32b132e60b023e7b40fb0135830@43.134.186.55:26656,1600b794c3727e5848efa593e16339789bad6320@116.203.41.7:16656,3daf63e0db3b31ca283bd488cca53d1987c9e244@20.214.108.227:16656,23b28771770bed1e9e30ba27d8d1d63d98549265@65.21.159.63:16656,d6d45352df7a280225ff4a7e1d43659090ee85ef@49.12.214.194:26656,a05b4aa229ec7b2ab55f74c248c51bcf10edc84e@193.46.243.36:16656,43ec65fcdd4184a245706646530ef56c55ae9af5@178.20.42.142:16656,fe57762fb3ffa460c24f27580ecf02f5ac2f7284@95.217.83.28:26656,654a986a730d86d9e1964b29f8a2e44c128337fd@68.183.20.25:26656,d18d5c74ddbc3d10d7bf7b5993f087744503956e@38.242.229.5:16656,8b02b40b6b90334f3999e3635423340e41be7369@168.119.124.158:26656,359c3f0a1ded2494cfd259e8a147f4fe6ae44bdf@65.108.43.116:56142,10177a2d1d3affad46f59aa4c90146155b8df02c@46.101.31.77:26656,965fcfeed138dd5b48bfb00af9760ae9b7f472d1@149.102.133.151:16656,ad707ba76faa82a4c06746f128bbc38f1a580587@144.126.214.175:16656,ac3f98fed63b5fda97da2a881dad470ac3c48620@65.109.6.13:26656,bed49868306a16da520265b547b5b6238d2b44d5@149.102.147.205:26656,49a6f352bdd6da0f96b8e358590cf40387385a79@209.97.134.97:16656,d7ecab7d47d75895a040b7d8a2204709d11f2128@207.180.202.209:16656,1c06803eb8dda04473f2a5d8419f26126d6d1b09@89.58.45.204:26656,bfe9b1e039e6162a6a5ad5bdf8c34958a15725cf@134.209.92.95:16656,42a2efd913df6f99f938ff3583680de1b5195ef6@45.147.199.212:26656,9e4231e1ef4247900d33b0d72483efa7fa7f95fe@62.84.113.145:26656,dbda1850f51992ad1ea9815ea32e0f7d6b1ae1a2@38.242.198.89:16656,ef3e8d69dbe4a06b88867b83b6eeac8e0476cf40@23.88.48.244:16656,2d57e10ddeb277cc9f1c996b053ed47837b41b18@43.134.224.140:26656,2b92f452d91305ea0d79c10530149f80171e3dbb@65.108.244.233:26656,37b59f5d4b569535ecaec2487d537385c3e3ebba@38.242.210.238:16656,d5a52e246601ea09f4543e43aab65fea113ce080@65.108.101.50:60556,eb4c6098bca86effb3b10f6cbe9858f111eebf85@161.35.235.232:26656,f2334364a4a5043356393b8badb1e95a27d29d6c@65.109.18.179:28656,ce660b7c24f534cc12ef5bf319f2874226bc3159@188.34.203.177:16656,1f3d95a6975a385bf5b116f92304ab6e82432dbe@35.223.121.130:16656,a4f730f72a72950378cd12c64ec8d22f0118d90d@167.172.151.205:16656,82f23836466a0c89bf7f0897927d301946e69818@62.113.117.138:26656,f9d8a9ddb2673837cad33a48186fd4caebe18209@86.48.0.4:16656,e70ae27c3fda9c43538447295b80a0cf32c77481@213.136.92.179:26656,3bae9347b7a6c148fa70cbd70b42a643d38e024d@95.217.11.20:36656,7c91ccb66c5fdc1732c75bd2f4f32f5b034cbbda@85.208.51.237:16656,364a15c3cde5174d7d32aaab3cf3d7f5c9dc4216@46.101.8.187:16656,fc8181e8d1c3349156988c67954aec6f8f470d25@194.146.25.9:26656,dfd520b1a87c5fed838ca5f924fac4d03004e6ef@161.97.145.67:16656,08bd5d064f7764a63ca3cdc04759242434b01c72@75.119.154.72:26656,3c9acfaf3586a4516440c2d46aa95fffa0f0a8fc@65.108.235.151:16656,c681b32987413894c662d168f421afb53e34addb@45.147.199.33:26656,0a526b1fe2882e1f971a8b53d5f8873910ce68f6@161.97.156.45:16656,6b0775bcff26a3c4aebf9e1eeca243bd226f82e7@185.202.223.85:16656,879d3aa92433eba4fe1f7c16291f53e3694a4b8e@167.99.226.2:16656,7c12e71eb64fd909900ba564cc5f4a64854a6cd0@38.242.242.196:26656,3161f3d8173611fd7c36c09bc7ee7fe4c5a9a564@45.67.217.30:16656,97ae665d7195aa21bb323ad85b9dff3e42519733@38.242.159.193:16656,f7e240ea5722083f8dcbcbf33f3d8246257c6b11@185.202.223.124:16656,a62d3b5b994408a6bfafaaa8ab4858225d7c8010@167.86.87.74:26656,b2bfbd43961b9f8f82c95bfe77631b222b366cb0@135.181.30.186:26656,8b1261901fa98c33f00749b37d5e3ce1949cf0af@34.171.239.198:16656,e81c14bd6d9c4c89109c933bf2dbd0390a17cba8@185.216.75.168:26656,74852aa59840ee11cb6041b534a2878d6633aa79@159.89.26.53:16656"
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

echo '=============== KURULUM BITTI www.nodeswizard.com ==================='
echo -e 'Loglari kontrol et: \e[1m\e[32mjournalctl -u strided -f -o cat\e[0m'
echo -e "senkrazasyon kontrol: \e[1m\e[32mcurl -s localhost:${STRIDE_PORT}657/status | jq .result.sync_info\e[0m"
