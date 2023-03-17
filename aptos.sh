#!/bin/bash
echo -e "\033[0;35m"

sleep 3

echo -e "\e[1m\e[32m1. Sunucu guncellemesi yapiliyor, docker kuruluyor.. \e[0m"
echo "======================================================"
sleep 1
sudo apt update && sudo apt upgrade -y
sudo apt install docker.io -y
mkdir -p ~/data/arbitrum
chmod -fR 777 ~/data/arbitrum

if [ ! $L1URL ]; then
	read -p "L1 Url adresinizi girin: " L1URL
	echo 'export L1URL='$L1URL >> $HOME/.bash_profile
fi


echo -e "\e[1m\e[32m1. Arbi node kuruluyor.. \e[0m"
echo "======================================================"
sleep 1

docker run -d -v ~/data/arbitrum:/home/user/.arbitrum -p 0.0.0.0:8547:8547 -p 0.0.0.0:8548:8548 offchainlabs/nitro-node:v2.0.11-rc.2-b3ab37e --l1.url $L1URL --l2.chain-id=42161 --http.api=net,web3,eth,debug --http.corsdomain=* --http.addr=0.0.0.0 --http.vhosts=* --init.url="https://snapshot.arbitrum.io/mainnet/db-archive.tar"
