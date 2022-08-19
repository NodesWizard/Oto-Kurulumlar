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
PEERS="17b24705533d633cb3501233a18912ae6cc36a41@stride-testnet.nodejumper.io:28656,29acbb3b3b9fa880944741c32617826cba44a624@78.47.214.203:26656,165f6cba877d71f0ad1c8ee6392beea35e04cb78@95.217.155.136:16656,390ff948ffbb9ad1793c3de91bf457750f3279b6@65.108.71.92:54356,aeabaf90afbe6321f2e8a33ddc5aebf2963f6efd@65.108.238.183:36656,328d459d21f82c759dda88b97ad56835c949d433@78.47.222.208:26639,ad4c545a806e151fe3cdd7e418b5544bc14a36d6@158.247.230.103:26656,d76de995b7c611e3edd651b828fd01f242015740@45.77.33.208:26656,23573e96a23292e97ce42a03260799f2a20415b6@88.198.39.43:26736,6c933f3ff3e529852e958f40c5d3c82296504e50@158.247.231.72:26656,3f1d13d7b9d499ca2c4647b844dab1d3a3f2a6ab@212.162.153.56:26656,dd93bd24192d8d3151264424e44b0f213d2334dc@162.55.173.64:26656,54a11c47658ebd5dcbd70eb3c62197b439482d3f@116.202.236.115:21016,d6e423fbd610dae4f0966cfed5b47165b4548582@45.91.168.197:26656,95ee745023b21aee6aa62c46352724b5f32240cd@161.97.91.70:16656,8deab2e38cd0a02bf2572340b6e082c59d856bae@2.59.156.145:26656,e4a2f835dc501cec2e87bac9b3365ff21bb87851@45.32.126.218:26656,8ff255af7f4d13429af028184a917093cddb92ff@185.216.75.46:16656,57fea82e70f8ffef72a3d09021796a52c43685d8@65.108.206.56:16656,abb29071e552fb1cd8ecae886c50ac3471a170c3@164.68.125.90:26656,01806f822366b27c4f63502eeec689abedb20438@38.242.128.46:16656,3b44079def8ad2dd8cbb14ce562957b5057b4e7b@65.108.204.115:26656,89fc167903c6f8afd519cbc8cc1542ac6467f911@135.181.133.248:11656,6cd4368f972c8e70f39f159804d2b0c89d603b7b@115.73.213.74:26656,c311f95b9c644c484671a096fc53297d4d5ae82e@86.48.2.178:26656,3983015b094e92c88b31250454c2093b39fe87c6@134.122.100.79:26656,866bb1cbc21bf1f1fd524717d536c1020bd26c45@49.12.237.93:26656,1a8a12acb9d68cfceef15826aa8183a755f038c1@159.65.81.42:26656,59e0c79c8c30ccd03e2f3d61d4f40b5f75223cd5@45.32.119.215:26656,375bf00a82d55f02ec6e44974a6848a4e8af8016@149.102.146.46:26656,45380044a09852b7fac0c6bc4da625128118fd04@45.77.241.50:26656,12090dadc2c6b1b90a4a2f77259f107a36c17242@65.108.249.29:16656,f0c7aaa7bcd159e4fe2775abc5968e3548af866d@34.135.153.30:16656,fcdda87767645df851c5405d9bb8601330a469c6@51.75.135.46:16656,d339b9a6df1b3f85f9da48134f59882456de1301@147.182.232.40:26656,e718e156dbc1b6644653debece7552de9a3f670f@185.220.205.98:16656,673cd2e8df973b8c10b1a460bd846e31b228373c@135.181.73.170:26757,9443ac82d9c5220e489e14be1335a871b9f6c552@178.62.122.192:26656,9988473a72d06d3eedec4eabafa677295015ce8e@65.108.137.92:26656,acc291258810e829db87a8babfa22cf82e217caa@141.147.7.113:26656,3aef99f334355ca0935855b72a5f8da23ded22a9@178.62.38.35:26656,8071611b00cacb8d6a71c1916b9045f70fc3b0ca@135.181.202.21:16656,8acff5bc80a9d286721d540047c53f7ad0d54f2b@95.216.153.211:16656,5387b1a0bef6fd279db6ab19ad64c4c117a45745@194.163.149.116:26656,1600b794c3727e5848efa593e16339789bad6320@116.203.41.7:16656,96cbb011ccd1573e0044a47b59b714ed03e5c4d5@65.21.147.17:16656,23b28771770bed1e9e30ba27d8d1d63d98549265@65.21.159.63:16656,d6d45352df7a280225ff4a7e1d43659090ee85ef@49.12.214.194:26656,8fcfe7566374d3c33abd11146ce71a81d55c3b8c@159.223.211.55:26656,43ec65fcdd4184a245706646530ef56c55ae9af5@178.20.42.142:16656,fe57762fb3ffa460c24f27580ecf02f5ac2f7284@95.217.83.28:26656,261b5c4bf10481ad6d2228799e356f27768e04ed@54.68.171.64:26656,d18d5c74ddbc3d10d7bf7b5993f087744503956e@38.242.229.5:16656,8b02b40b6b90334f3999e3635423340e41be7369@168.119.124.158:26656,359c3f0a1ded2494cfd259e8a147f4fe6ae44bdf@65.108.43.116:56142,d64cd93f3bb2e6a76b383bc089837d02076f6bc1@159.223.202.196:16656,965fcfeed138dd5b48bfb00af9760ae9b7f472d1@149.102.133.151:16656,c97299e5ed0c6ad0ca405001f528317e0d9b0970@159.203.191.62:26656,efa8a22c9ff4d4003935dd9579c6a4400dbe4368@38.242.244.34:26656,bed49868306a16da520265b547b5b6238d2b44d5@149.102.147.205:26656,04504878ab54e214a0d08bbbb40c0339b259514c@20.117.210.30:26656,ff1ae727a816983a826e48b9fb5d7d2cebe40e78@95.214.55.4:26656,1c06803eb8dda04473f2a5d8419f26126d6d1b09@89.58.45.204:26656,49a6f352bdd6da0f96b8e358590cf40387385a79@209.97.134.97:16656"
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

echo '=============== KURULUM BITTI www.nodeswizard.com ==================='
echo -e 'Loglari kontrol et: \e[1m\e[32mjournalctl -u strided -f -o cat\e[0m'
echo -e "senkrazasyon kontrol: \e[1m\e[32mcurl -s localhost:${STRIDE_PORT}657/status | jq .result.sync_info\e[0m"
