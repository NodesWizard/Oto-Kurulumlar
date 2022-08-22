#!/bin/bash
echo -e "\033[0;35m"
echo "  _   _  ____  _____  ______  _______          _______ ______         _____  _____    ";
echo " | \ | |/ __ \|  __ \|  ____|/ ____\ \        / /_   _|___  /   /\   |  __ \|  __ \   ";
echo " |  \| | |  | | |  | | |__  | (___  \ \  /\  / /  | |    / /   /  \  | |__) | |  | |  ";
echo " | |\  | |__| | |__| | |____ ____) |  \  /\  /   _| |_ / /__ / ____ \| | \ \| |__| |  ";
echo " |_| \_|\____/|_____/|______|_____/    \/  \/   |_____/_____/_/    \_\_|  \_\_____/   ";
echo -e "\e[0m"    

sleep 1

systemctl stop suid
systemctl disable suid

sleep 2

rm -rf $HOME/.sui /usr/local/bin/sui*

sleep 2

rm -rf $HOME/.sui/db

sleep 2

sudo rm -rf /var/sui/db

sleep 1

sudo rm -rf sui

sleep 1

sudo rm -rf .sui

sleep 1

sudo rm -rf sui.sh

sleep 1

sudo apt update && sudo apt upgrade -y

sleep 2

wget -qO update.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/sui/tools/update.sh && chmod +x update.sh && ./update.sh

sleep 2

echo -e "\e[1m\e[32mhttps://node.sui.zvalid.com/ -- kontrol et -- TRANS BOLUMU 0 OLURSA ARADA FIXED SCRPTINI ÇALIŞTIR \e[0m"

sleep 2
