#!/bin/bash
echo -e "\033[0;35m"
echo "  _   _  ____  _____  ______  _______          _______ ______         _____  _____    ";
echo " | \ | |/ __ \|  __ \|  ____|/ ____\ \        / /_   _|___  /   /\   |  __ \|  __ \   ";
echo " |  \| | |  | | |  | | |__  | (___  \ \  /\  / /  | |    / /   /  \  | |__) | |  | |  ";
echo " | |\  | |__| | |__| | |____ ____) |  \  /\  /   _| |_ / /__ / ____ \| | \ \| |__| |  ";
echo " |_| \_|\____/|_____/|______|_____/    \/  \/   |_____/_____/_/    \_\_|  \_\_____/   ";
echo -e "\e[0m"  

sleep 2

sudo ufw allow 8421
sudo ufw allow 8420

sleep 1

sudo apt-get update && sudo apt-get upgrade -y

sleep 1

git clone https://github.com/git/git

sleep 1

sudo apt install -y build-essential libssl-dev libffi-dev git curl screen -y

sleep 1

sudo apt install screen -y

sleep 1

sudo apt update && sudo apt install python3.10-venv -y

sleep 1

sudo apt update
sudo apt install python3-venv python3-pip -y

sleep 2

git clone https://github.com/newrlfoundation/newrl.git
cd newrl
scripts/install.sh testnet



