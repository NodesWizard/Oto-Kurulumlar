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
PEERS="17b24705533d633cb3501233a18912ae6cc36a41@stride-testnet.nodejumper.io:28656,29acbb3b3b9fa880944741c32617826cba44a624@78.47.214.203:26656,165f6cba877d71f0ad1c8ee6392beea35e04cb78@95.217.155.136:16656,390ff948ffbb9ad1793c3de91bf457750f3279b6@65.108.71.92:54356,aeabaf90afbe6321f2e8a33ddc5aebf2963f6efd@65.108.238.183:36656,328d459d21f82c759dda88b97ad56835c949d433@78.47.222.208:26639,3c026c885afa0ce9cf544a4379dcec6265342d18@38.242.205.70:26656,d76de995b7c611e3edd651b828fd01f242015740@45.77.33.208:26656,23573e96a23292e97ce42a03260799f2a20415b6@88.198.39.43:26736,6c933f3ff3e529852e958f40c5d3c82296504e50@158.247.231.72:26656,3f1d13d7b9d499ca2c4647b844dab1d3a3f2a6ab@212.162.153.56:26656,dd93bd24192d8d3151264424e44b0f213d2334dc@162.55.173.64:26656,e15c366f195d65885b595d678be18ad6f822b80f@185.252.235.89:16656,d6e423fbd610dae4f0966cfed5b47165b4548582@45.91.168.197:26656,95ee745023b21aee6aa62c46352724b5f32240cd@161.97.91.70:16656,8deab2e38cd0a02bf2572340b6e082c59d856bae@2.59.156.145:26656,e4a2f835dc501cec2e87bac9b3365ff21bb87851@45.32.126.218:26656,8ff255af7f4d13429af028184a917093cddb92ff@185.216.75.46:16656,57fea82e70f8ffef72a3d09021796a52c43685d8@65.108.206.56:16656,abb29071e552fb1cd8ecae886c50ac3471a170c3@164.68.125.90:26656,01806f822366b27c4f63502eeec689abedb20438@38.242.128.46:16656,3b44079def8ad2dd8cbb14ce562957b5057b4e7b@65.108.204.115:26656,89fc167903c6f8afd519cbc8cc1542ac6467f911@135.181.133.248:11656,6cd4368f972c8e70f39f159804d2b0c89d603b7b@115.73.213.74:26656,f8d187d02876bf40a24acbb1b4e08254adda40ad@92.100.157.81:26656,3983015b094e92c88b31250454c2093b39fe87c6@134.122.100.79:26656,866bb1cbc21bf1f1fd524717d536c1020bd26c45@49.12.237.93:26656,1a8a12acb9d68cfceef15826aa8183a755f038c1@159.65.81.42:26656,59e0c79c8c30ccd03e2f3d61d4f40b5f75223cd5@45.32.119.215:26656,375bf00a82d55f02ec6e44974a6848a4e8af8016@149.102.146.46:26656,45380044a09852b7fac0c6bc4da625128118fd04@45.77.241.50:26656,12090dadc2c6b1b90a4a2f77259f107a36c17242@65.108.249.29:16656,f0c7aaa7bcd159e4fe2775abc5968e3548af866d@34.135.153.30:16656,fcdda87767645df851c5405d9bb8601330a469c6@51.75.135.46:16656,e1ac927286e5b899aa2b93fbeb44677ec673e9f3@20.94.46.231:16656,e718e156dbc1b6644653debece7552de9a3f670f@185.220.205.98:16656,673cd2e8df973b8c10b1a460bd846e31b228373c@135.181.73.170:26757,9443ac82d9c5220e489e14be1335a871b9f6c552@178.62.122.192:26656,9988473a72d06d3eedec4eabafa677295015ce8e@65.108.137.92:26656,acc291258810e829db87a8babfa22cf82e217caa@141.147.7.113:26656,3aef99f334355ca0935855b72a5f8da23ded22a9@178.62.38.35:26656,e28ccdf2ba15eeb130d48c1eba5bfd87a28d4e44@136.243.54.229:26656,8acff5bc80a9d286721d540047c53f7ad0d54f2b@95.216.153.211:16656,5387b1a0bef6fd279db6ab19ad64c4c117a45745@194.163.149.116:26656,1600b794c3727e5848efa593e16339789bad6320@116.203.41.7:16656,96cbb011ccd1573e0044a47b59b714ed03e5c4d5@65.21.147.17:16656,23b28771770bed1e9e30ba27d8d1d63d98549265@65.21.159.63:16656,d6d45352df7a280225ff4a7e1d43659090ee85ef@49.12.214.194:26656,8fcfe7566374d3c33abd11146ce71a81d55c3b8c@159.223.211.55:26656,43ec65fcdd4184a245706646530ef56c55ae9af5@178.20.42.142:16656,fe57762fb3ffa460c24f27580ecf02f5ac2f7284@95.217.83.28:26656,261b5c4bf10481ad6d2228799e356f27768e04ed@54.68.171.64:26656,d18d5c74ddbc3d10d7bf7b5993f087744503956e@38.242.229.5:16656,8b02b40b6b90334f3999e3635423340e41be7369@168.119.124.158:26656,359c3f0a1ded2494cfd259e8a147f4fe6ae44bdf@65.108.43.116:56142,d64cd93f3bb2e6a76b383bc089837d02076f6bc1@159.223.202.196:16656,965fcfeed138dd5b48bfb00af9760ae9b7f472d1@149.102.133.151:16656,c97299e5ed0c6ad0ca405001f528317e0d9b0970@159.203.191.62:26656,efa8a22c9ff4d4003935dd9579c6a4400dbe4368@38.242.244.34:26656,bed49868306a16da520265b547b5b6238d2b44d5@149.102.147.205:26656,49a6f352bdd6da0f96b8e358590cf40387385a79@209.97.134.97:16656,6e253226b7c41dde06124f5965bcd114e2c5fec1@212.86.104.229:16656,1c06803eb8dda04473f2a5d8419f26126d6d1b09@89.58.45.204:26656,bfe9b1e039e6162a6a5ad5bdf8c34958a15725cf@134.209.92.95:16656,ed9880d350620ba0f47230a596aab0f7acf00ec1@128.199.245.209:16656,9e4231e1ef4247900d33b0d72483efa7fa7f95fe@62.84.113.145:26656,dbda1850f51992ad1ea9815ea32e0f7d6b1ae1a2@38.242.198.89:16656,0c6ec29b87700618189daf7c3af5761ae528c4d6@5.189.170.154:16656,04504878ab54e214a0d08bbbb40c0339b259514c@20.117.210.30:26656,f11b08f033b79699d3727cc4e7cf11923c3fc0a8@195.201.106.36:22656,37b59f5d4b569535ecaec2487d537385c3e3ebba@38.242.210.238:16656,d5a52e246601ea09f4543e43aab65fea113ce080@65.108.101.50:60556,10177a2d1d3affad46f59aa4c90146155b8df02c@46.101.31.77:26656,f2334364a4a5043356393b8badb1e95a27d29d6c@65.109.18.179:28656,ce660b7c24f534cc12ef5bf319f2874226bc3159@188.34.203.177:16656,d58e942624af9734608867f99745628f987cf1fa@46.0.234.246:26656,6557ad833ea55b0b3ccb90052efb6b205abf568b@159.223.146.223:16656,57fdea9e432439cc3fb93f5ea001aa96b51f9889@165.232.152.40:16656,4093d2bbca52d981f6a61f88d7bbbcacdb0fa800@159.223.217.100:16656,9db0e767b8a58fce89371fc3e9cbe111c0320196@142.93.105.5:16656,198123cad9a9a5b4eb052c2c7b233078e44acd38@142.132.202.50:26651,75a296bd90a764d744b41c50b50490da721880d0@95.214.55.4:26656,364a15c3cde5174d7d32aaab3cf3d7f5c9dc4216@46.101.8.187:16656,98ec061c5ed3335a8573206f1ae1328d5cea42ee@83.136.251.210:26656,dfd520b1a87c5fed838ca5f924fac4d03004e6ef@161.97.145.67:16656,e8258197ad814ee250dbe921593da112e2486e16@34.171.149.140:16656,f398419bd204f96706f4a27ea5681ed98bb47b10@38.242.238.46:26656,93f4941dcdb396168193571036cbad8d375be65e@185.197.194.200:16656,0a526b1fe2882e1f971a8b53d5f8873910ce68f6@161.97.156.45:16656,6b0775bcff26a3c4aebf9e1eeca243bd226f82e7@185.202.223.85:16656,879d3aa92433eba4fe1f7c16291f53e3694a4b8e@167.99.226.2:16656,7c12e71eb64fd909900ba564cc5f4a64854a6cd0@38.242.242.196:26656,7771775aec44f0ace6cd8b1c4565816ba1911601@34.125.120.81:16656,97ae665d7195aa21bb323ad85b9dff3e42519733@38.242.159.193:16656,f7e240ea5722083f8dcbcbf33f3d8246257c6b11@185.202.223.124:16656,a62d3b5b994408a6bfafaaa8ab4858225d7c8010@167.86.87.74:26656,8a381743d137b67a895ee57b1d1da663503e4d73@78.47.234.165:26656,c0d9bb865de01bc8b45c69f27892ca691d2c2324@45.32.103.189:16656,e81c14bd6d9c4c89109c933bf2dbd0390a17cba8@185.216.75.168:26656,74852aa59840ee11cb6041b534a2878d6633aa79@159.89.26.53:16656"
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
