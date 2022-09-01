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
	read -p "Node ismi girin: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
CELESTIA_PORT=20
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export CELESTIA_CHAIN_ID=mamaki" >> $HOME/.bash_profile
echo "export CELESTIA_PORT=${CELESTIA_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo -e "node isminiz: \e[1m\e[32m$NODENAME\e[0m"
echo -e "wallet isminiz: \e[1m\e[32m$WALLET\e[0m"
echo -e "chain ismi: \e[1m\e[32m$CELESTIA_CHAIN_ID\e[0m"
echo -e "kullanilan port: \e[1m\e[32m$CELESTIA_PORT\e[0m"
echo '================================================='
sleep 2

echo -e "\e[1m\e[32m1. biseyler guncelleniyorrrr... \e[0m" && sleep 1
# update
sudo apt update && sudo apt upgrade -y

echo -e "\e[1m\e[32m2. o su bu iniyor... \e[0m" && sleep 1
# packages
sudo apt install curl build-essential git wget jq make gcc tmux chrony -y

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

echo -e "\e[1m\e[32m3. biseyler daha iniyor... \e[0m" && sleep 1
# download binary
cd $HOME
rm -rf celestia-app
git clone https://github.com/celestiaorg/celestia-app.git
cd celestia-app
APP_VERSION=$(curl -s https://api.github.com/repos/celestiaorg/celestia-app/releases/latest | jq -r ".tag_name")
git checkout tags/$APP_VERSION -b $APP_VERSION
make install

# download network tools
cd $HOME
rm -rf networks
git clone https://github.com/celestiaorg/networks.git

# config
celestia-appd config chain-id $CELESTIA_CHAIN_ID
celestia-appd config keyring-backend test
celestia-appd config node tcp://localhost:${CELESTIA_PORT}657

# init
celestia-appd init $NODENAME --chain-id $CELESTIA_CHAIN_ID

# download genesis and addrbook
cp $HOME/networks/$CELESTIA_CHAIN_ID/genesis.json $HOME/.celestia-app/config

# set seeds, peers and boot nodes
BOOTSTRAP_PEERS=$(curl -sL https://raw.githubusercontent.com/celestiaorg/networks/master/mamaki/bootstrap-peers.txt | tr -d '\n')
MY_PEER=$(celestia-appd tendermint show-node-id)@$(curl -s ifconfig.me)$(grep -A 9 "\[p2p\]" ~/.celestia-app/config/config.toml | egrep -o ":[0-9]+")
PEERS=$(curl -sL https://raw.githubusercontent.com/celestiaorg/networks/master/mamaki/peers.txt | tr -d '\n' | head -c -1 | sed s/"$MY_PEER"// | sed "s/,,/,/g")
sed -i.bak -e "s/^bootstrap-peers *=.*/bootstrap-peers = \"$BOOTSTRAP_PEERS\"/" $HOME/.celestia-app/config/config.toml
sed -i.bak -e "s/^persistent-peers *=.*/persistent-peers = \"$PEERS\"/" $HOME/.celestia-app/config/config.toml

# use custom settings
use_legacy="false"
pex="true"
max_connections="90"
peer_gossip_sleep_duration="2ms"
sed -i.bak -e "s/^use-legacy *=.*/use-legacy = \"$use_legacy\"/" $HOME/.celestia-app/config/config.toml
sed -i.bak -e "s/^pex *=.*/pex = \"$pex\"/" $HOME/.celestia-app/config/config.toml
sed -i.bak -e "s/^max-connections *=.*/max-connections = \"$max_connections\"/" $HOME/.celestia-app/config/config.toml
sed -i.bak -e "s/^peer-gossip-sleep-duration *=.*/peer-gossip-sleep-duration = \"$peer_gossip_sleep_duration\"/" $HOME/.celestia-app/config/config.toml

# set custom ports
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${CELESTIA_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${CELESTIA_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${CELESTIA_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${CELESTIA_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${CELESTIA_PORT}660\"%" $HOME/.celestia-app/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${CELESTIA_PORT}317\"%; s%^address = \":8080\"%address = \":${CELESTIA_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${CELESTIA_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${CELESTIA_PORT}091\"%" $HOME/.celestia-app/config/app.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.celestia-app/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.celestia-app/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.celestia-app/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.celestia-app/config/app.toml

# set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0utia\"/" $HOME/.celestia-app/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.celestia-app/config/config.toml

# reset
celestia-appd tendermint unsafe-reset-all --home $HOME/.celestia-app

echo -e "\e[1m\e[32m4. servisler basliyor.. \e[0m" && sleep 1
# create service
sudo tee /etc/systemd/system/celestia-appd.service > /dev/null <<EOF
[Unit]
Description=celestia
After=network-online.target

[Service]
User=$USER
ExecStart=$(which celestia-appd) start --home $HOME/.celestia-app
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
sudo systemctl enable celestia-appd
sudo systemctl restart celestia-appd

sleep 2

cd $HOME
rm -rf ~/.celestia-app/data
mkdir -p ~/.celestia-app/data
SNAP_NAME=$(curl -s https://snaps.qubelabs.io/celestia/ | \
    egrep -o ">mamaki.*tar" | tr -d ">")
wget -O - https://snaps.qubelabs.io/celestia/${SNAP_NAME} | tar xf - \
    -C ~/.celestia-app/data/
    
sleep 2

PEERS="45d8b18cc8875d458c5201c7a491a4ea782da002@161.97.142.218:26656,a46bbdb81e66c950e3cdbe5ee748a2d6bdb185dd@161.97.168.77:55156,13e773f70a4ad3ad31f3d905daf67b671b2b8796@167.86.103.158:26656,5273f0deefa5f9c2d0a3bbf70840bb44c65d835c@80.190.129.50:22667,216d9791a69c8f4ea05967904c929a33c01a0691@142.132.232.41:57806,f953efd4a29e4dbee52924b1ccef96a5060dfc4f@135.181.199.224:40452,e151b6f494aa0f503a2d8da5e6daf78ec5ff8dab@185.229.119.123:32932,1d5f32e1b162b7dd289dce98fbf59fcb1cd916ba@195.201.168.245:52944,ea6a6f8075db7c886ea7d4f72757b80e220a4846@45.94.58.221:45652,c380645b14ed906b4ef915c33da2aa8e4ca8f89c@167.235.71.35:26656,43e9da043318a4ea0141259c17fcb06ecff816af@141.94.73.39:40646,7145da826bbf64f06aa4ad296b850fd697a211cc@176.57.189.212:51476,cd1524191300d6354d6a322ab0bca1d7c8ddfd01@95.216.223.149:26656,d541469b73bf72d3a51b1d9d63f0f6e5ba50cd52@65.108.208.50:42270,7dd792ff914f7ad341244958815647a8b853f663@135.181.252.34:49398,5d87d3bc979710ee5f5c63aa85f7fa1451f777a8@65.108.79.246:26676,c3d1222a07a51558e5c77803d036a4cc33db14f9@95.216.213.241:26656,ac39724c87e6cbe75829f3129bf1d7047a0244db@95.217.15.171:26656,a39af9609c8c2cf80e2eb6af4fdeb55e4c60eb1d@23.88.52.24:32699,b5b1c7edcd83288c227b98126ab0dae7df956893@82.165.254.199:26656,7676c23ca63126b65718c2b4019a41d1d2fa31da@65.108.48.157:26656,79be0ec0a297210908448ef03c25e0a3e5b2fb51@141.95.101.104:26656,f22ac1824018940e3c0e033faf6e227cfcd551f7@138.201.197.163:26656,f59e601cc1e22dc25bd00bb25f1ff74e4ac19c60@78.46.162.213:26656,fe2025284ad9517ee6e8b027024cf4ae17e320c9@198.244.164.11:51082,af89462454af4ceae623d6af26364edc616b3a26@75.119.155.243:26656,f4b42993f568436b1b57e85c977394b78cb5de1a@159.65.217.114:26656,9f449c0a4bcc489f0c0a15e9fd29f19c8c348b96@194.163.165.246:26656,eab2ffe72bb367123cceb84b2a9ae5a3fafb2689@95.216.209.194:26656,d81253ef12fce2e243fe48d64fa2841de2ef6072@95.216.94.109:26656,95083abed5cacef0f3ad7166b554c022498789d1@136.243.88.91:36810,f7268d048468d6c4d03caa613ac1fb67b79bc7d1@168.119.63.208:26656,17513575d394d9316165f2b023652b7f4fc1ba04@154.53.35.235:26656,5405d41d092f62824122044415f048a016e0a75e@65.108.43.116:56103,763eaad1dcf75a6edca3cb7a5c518819da704fb1@116.203.151.147:26656,c1df179eb18b013b71e3b649fd1a14eb756eeaa9@95.216.242.138:26656,1a79b2e2cf2bbe5275a4a58c3425d77e9b678e82@38.242.202.182:26656,1e85ef9f5161ec7bcb358f663071dbd98f4ad6e9@159.223.189.6:26656,989c3fdaa5e1d1fb59adc6db39624b1f049311e1@167.172.252.137:26656,e81a5545ce8c0142dd942ed300875b1f218a1af1@91.205.174.57:26656,7516179c6e045ab88d5732eb372f6dcb405e9778@167.86.103.3:26656,6ebf3b5240c5b11077b4aca2e36c26f701f67bd9@5.189.189.254:26656,47036c3d7a2d18e4aacb85fcb801091e6327e047@65.21.232.112:26656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.celestia-app/config/config.toml

sleep 2

systemctl restart celestia-appd

echo '=============== kurulum bitti ==================='
echo -e 'logları kontrol etsss: \e[1m\e[32mjournalctl -u celestia-appd -f -o cat\e[0m'
echo -e "false misin gontrol et: \e[1m\e[32mcurl -s localhost:${CELESTIA_PORT}657/status | jq .result.sync_info\e[0m"
