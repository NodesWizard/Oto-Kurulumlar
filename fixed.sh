#!/bin/bash

echo -e "\033[0;35m"
echo "  _   _  ____  _____  ______  _______          _______ ______         _____  _____    ";
echo " | \ | |/ __ \|  __ \|  ____|/ ____\ \        / /_   _|___  /   /\   |  __ \|  __ \   ";
echo " |  \| | |  | | |  | | |__  | (___  \ \  /\  / /  | |    / /   /  \  | |__) | |  | |  ";
echo " | |\  | |__| | |__| | |____ ____) |  \  /\  /   _| |_ / /__ / ____ \| | \ \| |__| |  ";
echo " |_| \_|\____/|_____/|______|_____/    \/  \/   |_____/_____/_/    \_\_|  \_\_____/   ";
echo -e "\e[0m"  

sleep 2

systemctl stop suid; \
rm -rf $HOME/.sui/db; \
systemctl restart suid

sleep 2

echo -e "\e[1m\e[32mhttps://node.sui.zvalid.com/ -- Arada kontrol et -- TRANS BOLUMU 0 OLURSA TEKRAR ÇALIŞTIR \e[0m"

sleep 2
