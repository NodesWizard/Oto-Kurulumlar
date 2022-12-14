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
PEERS="79a4dc86281be42768d33f25807ff5ab80c3c916@75.119.134.69:26656,422c1e98964d04e92c1e847d7214ad01695c42a6@209.126.80.91:26656,767da520aa74b24904070327761add8512540c87@62.171.132.152:26656,a8793bb26c86089febec165300be03f0a8627dc8@77.37.176.99:46656,09a5075aa7a1075c90f72d663312ea49f491ebbf@142.132.196.251:26656,da6130e91acde648d23dda2847587f2cee86fb14@213.136.92.246:46656,2c41343e6bdd43950e485bfefe43cce9bf2b6bbd@176.37.119.156:26656,055cf1973026f65a2cee4c266a2dd2fa31f4fd4f@65.108.209.4:26656,4a07e3296fee5bdc2a45f7c5e6348168a1c9b286@144.91.125.55:26656,ad45a4fe1e9e8a6edd8654924b7b6c1638f0214a@54.39.243.226:26656,6e1d04b313c961031ab40409f40e99568d2190ba@198.204.255.155:26656,a8bc5ae440dd0ee13f091cd1b17d104c1a7b498c@95.217.225.214:29656,d46df63e3b900740496fcba19e4ea926e8ce8582@206.189.13.159:26656,c5b45045b0555c439d94f4d81a5ec4d1a578f98c@135.181.133.93:27656,0d25212f510f8868b639861de96ccd31fc1ea4dc@65.21.61.242:26656,325b79115ca4ce4ff7cca054061cd347d694dadc@159.69.93.251:26656,a14fd0c96afc2cfd6894812a0a7ab2b99e81cfee@62.171.173.58:26656,144067fb454eea6dc6b207dcc415a0213e27c40a@146.19.24.101:26636,d23354d5c60b723f315c28d0dc321aff2e7eedcb@5.161.80.30:14656,674088d85d41b5086029a4136625764071f17db8@5.161.86.210:14656,cfc175e44cf206d8175c91bdbef434c5b59f2461@94.130.50.61:28656,2c567b714bc64fdb22c4dfc7983b84aa64f0c7cc@45.10.154.174:26656,42558363e2e153b8ad9c618d2e5335d03ff09a60@167.86.95.179:26656,fadb42aa4e0ed2183a8d88488f28e44413492882@141.94.254.145:47656,054dfabf7ea154d41b085e20d42c7313f2eb2d48@62.171.148.163:26656,ae72548f31f409a92fc00e5b62b513f8261ea7ec@144.91.118.61:26656,ce1f8a507d88f60594186a8d2ce8e47e9919c95f@65.21.104.130:34656,b3f3977f10eee41ee7203aad0aaa99b1d56ff1f1@65.108.199.79:26656,c1fb7595e3922ab805ce4e9010ca8d94521edf6b@144.91.92.219:26656,64befdb7b718951faf9ce6244a96b791b6913594@95.216.70.104:26666,93cbda2c718a02b96497af25c639385cb08adb8f@206.246.74.33:26656,2c50234b5a740899c18b6d1c3f0be83d2c30a8c0@38.242.216.50:26656,151d897c0236fde8c52b9c61bcb37c02dd37c9a2@65.108.199.222:25656,cb881cdf6f3d9fa02034eeb835c174517d960595@65.108.120.21:26101,54ac40f4e4f4cca401c003f4065905ce91f5161a@85.10.198.171:16656,b0ad09ee5a5f6a54c98e0bcdc717a9813113a888@147.135.162.128:26656,2f40a727a89deca71e7a7605d69720bf47ff92cc@80.254.8.54:14656,b8a77e817bb619c02dcad1ef11463d5ddc090f3b@185.9.144.138:26656,dc6071eef218f56ccd0ce470a2055243d5be7df9@144.76.27.79:60556,cb832c5b3ed839927cbe720db292101e377f13fe@159.69.149.85:36656,cee858f842bb7c5e13db1986cbd09b10553a2848@178.238.225.58:26656,ee85cb0d941dca5759487f908c7339e2eea568ab@141.94.139.233:27656,69792df8475149b71de899f88e60e9b45788aa5e@65.21.224.26:26656,3c29c80c62b17cfc593bf063fc1273f89c8dcb1a@65.109.5.239:12356,56a057a6033664214c43ffadcf3c3ecfdfdf5d2a@209.126.81.240:26656,9440fa39f85bea005514f0191d4550a1c9d310bb@135.181.133.37:27656,6fdcc3dd767435ae58f7703f0d91ad2c07730ccd@88.208.57.200:60856,63064d9fe6bdffe6a85154592ec36be48cd63b9e@116.202.236.115:21046,741d3e3e56a5d0e2a11d84e5552e9f71556992b3@195.154.165.153:26656,bfbcc9759593f83b6c34522569de77d60f026c40@62.171.181.252:14656,294eb22071d922486c363e0a56e179e507d2be21@138.201.91.105:14656,fd2fa55269a9c9b1efdea72bb8293ba4203c9962@144.76.224.246:16656,344875eae57898c81892578e32232e2b9a32f1ca@5.189.183.206:26656"
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

sleep 2

sudo apt update
sudo apt install lz4 -y

sleep 2

sudo systemctl stop dewebd

sleep 2

cp $HOME/.deweb/data/priv_validator_state.json $HOME/.deweb/priv_validator_state.json.backup
dewebd tendermint unsafe-reset-all --home $HOME/.deweb --keep-addr-book

sleep 2

rm -rf $HOME/.deweb/data 
rm -rf $HOME/.deweb/wasm

sleep 2

SNAP_NAME=$(curl -s https://snapshots1-testnet.nodejumper.io/dws-testnet/ | egrep -o ">deweb-testnet-sirius.*\.tar.lz4" | tr -d ">")
curl https://snapshots1-testnet.nodejumper.io/dws-testnet/${SNAP_NAME} | lz4 -dc - | tar -xf - -C $HOME/.deweb

sleep 2

mv $HOME/.deweb/priv_validator_state.json.backup $HOME/.deweb/data/priv_validator_state.json

sleep 2

sudo systemctl restart dewebd


echo '=============== SETUP FINISHED ==================='
echo -e 'To check logs: \e[1m\e[32mjournalctl -u dewebd -f -o cat\e[0m'
echo -e "To check sync status: \e[1m\e[32mcurl -s localhost:${DEWEB_PORT}657/status | jq .result.sync_info\e[0m"
