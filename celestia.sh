#!/bin/bash

echo -e "\033[0;35m"
echo "  _   _  ____  _____  ______  _______          _______ ______         _____  _____    ";
echo " | \ | |/ __ \|  __ \|  ____|/ ____\ \        / /_   _|___  /   /\   |  __ \|  __ \   ";
echo " |  \| | |  | | |  | | |__  | (___  \ \  /\  / /  | |    / /   /  \  | |__) | |  | |  ";
echo " | |\  | |__| | |__| | |____ ____) |  \  /\  /   _| |_ / /__ / ____ \| | \ \| |__| |  ";
echo " |_| \_|\____/|_____/|______|_____/    \/  \/   |_____/_____/_/    \_\_|  \_\_____/   ";
echo -e "\e[0m"

sleep 1

if [ ! $CELESTIA_NODENAME ]; then
	read -p "NODE ISMI: " CELESTIA_NODENAME
	echo 'export CELESTIA_NODENAME='$CELESTIA_NODENAME >> $HOME/.bash_profile
fi

sleep 1

sudo apt update && sudo apt upgrade -y

sleep 1

sudo apt install make clang pkg-config libssl-dev build-essential git jq ncdu bsdmainutils -y < "/dev/null"

sleep 1

cd $HOME
wget -O go1.18.2.linux-amd64.tar.gz https://go.dev/dl/go1.18.2.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.18.2.linux-amd64.tar.gz && rm go1.18.2.linux-amd64.tar.gz
echo 'export GOROOT=/usr/local/go' >> $HOME/.bashrc
echo 'export GOPATH=$HOME/go' >> $HOME/.bashrc
echo 'export GO111MODULE=on' >> $HOME/.bashrc
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bashrc && . $HOME/.bashrc
go version

sleep 1

cd $HOME
rm -rf celestia-app

sleep 1

git clone https://github.com/celestiaorg/celestia-app.git

sleep 1

cd celestia-app/
APP_VERSION=$(curl -s \
  https://api.github.com/repos/celestiaorg/celestia-app/releases/latest \
  | jq -r ".tag_name")
  
sleep 1

git checkout tags/$APP_VERSION -b $APP_VERSION

sleep 1

make install

sleep 1

cd $HOME
celestia-appd init $CELESTIA_NODENAME --chain-id mamaki

sleep 1

pruning="custom"
pruning_keep_recent="100"
pruning_interval="10"

sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.celestia-app/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \
\"$pruning_keep_recent\"/" $HOME/.celestia-app/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \
\"$pruning_interval\"/" $HOME/.celestia-app/config/app.toml

sleep 1

sed -i.bak -e "s/^timeout-commit *=.*/timeout-commit = \"25s\"/" $HOME/.celestia-app/config/config.toml
sed -i.bak -e "s/^skip-timeout-commit *=.*/skip-timeout-commit = false/" $HOME/.celestia-app/config/config.toml
sed -i.bak -e "s/^mode *=.*/mode = \"validator\"/" $HOME/.celestia-app/config/config.toml

sleep 1

wget -O $HOME/.celestia-app/config/genesis.json "https://raw.githubusercontent.com/celestiaorg/networks/master/mamaki/genesis.json"

sleep 1

BOOTSTRAP_PEERS=$(curl -sL https://raw.githubusercontent.com/celestiaorg/networks/master/mamaki/bootstrap-peers.txt | tr -d '\n') && echo $BOOTSTRAP_PEERS
sed -i.bak -e "s/^bootstrap-peers *=.*/bootstrap-peers = \"$BOOTSTRAP_PEERS\"/" $HOME/.celestia-app/config/config.toml

sleep 1

PEERS="7145da826bbf64f06aa4ad296b850fd697a211cc@176.57.189.212:26656, f7b68a491bae4b10dbab09bb3a875781a01274a5@65.108.199.79:20356, 853a9fbb633aed7b6a8c759ba99d1a7674b706a3@38.242.216.151:26656, 96995456b7fe3ab6524fc896dec76d9ba79d420c@212.125.21.178:26656, 268694eaf9446b2052b1161979bf2e09f3e45e81@173.212.254.166:26656, 28aaa8865f3e9bba69f257b08d5c28091b5b3167@176.57.150.79:26656"
  
sleep 1

sed -i.bak -e "s/^persistent-peers *=.*/persistent-peers = \"$PEERS\"/" $HOME/.celestia-app/config/config.toml

sleep 1

sed -i.bak -e "s/^timeout-commit *=.*/timeout-commit = \"25s\"/" $HOME/.celestia-app/config/config.toml

sleep 1

sed -i.bak -e "s/^skip-timeout-commit *=.*/skip-timeout-commit = false/" $HOME/.celestia-app/config/config.toml

sleep 1

sed -i.bak -e "s/^mode *=.*/mode = \"validator\"/" $HOME/.celestia-app/config/config.toml

sleep 1

sudo tee <<EOF >/dev/null /etc/systemd/system/celestia-appd.service
[Unit]
Description=celestia-appd Cosmos daemon
After=network-online.target

[Service]
User=$USER
ExecStart=$HOME/go/bin/celestia-appd start
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

sleep 1

cat /etc/systemd/system/celestia-appd.service

sleep 1

cd $HOME/.celestia-app
celestia-appd tendermint unsafe-reset-all --home "$HOME/.celestia-app"

sleep 1

cd $HOME
rm -rf ~/.celestia-app/data

sleep 1

mkdir -p ~/.celestia-app/data

sleep 1

SNAP_NAME=$(curl -s https://snaps.qubelabs.io/celestia/ | \
    egrep -o ">mamaki.*tar" | tr -d ">")
wget -O - https://snaps.qubelabs.io/celestia/${SNAP_NAME} | tar xf - \
    -C ~/.celestia-app/data/
    
sleep 1

sudo systemctl enable celestia-appd
sudo systemctl start celestia-appd

sleep 1


echo -e 'LOG KONTROL : \e[1m\e[32msudo journalctl -u celestia-appd.service -f\e[0m'
echo -e 'Senkrazisyon KONTROL : \e[1m\e[32mcurl -s localhost:26657/status | jq .result | jq .sync_info\e[0m'
