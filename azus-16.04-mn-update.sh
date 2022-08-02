#!/bin/bash

#stop_daemon function
function stop_daemon {
    if pgrep -x 'azusd ' > /dev/null; then
        echo -e "${YELLOW}Attempting to stop azusd ${NC}"
        azusd-cli stop
        sleep 30
        if pgrep -x 'azusd ' > /dev/null; then
            echo -e "${RED}azusd  daemon is still running!${NC} \a"
            echo -e "${RED}Attempting to kill...${NC}"
            sudo pkill -9 azusd 
            sleep 30
            if pgrep -x 'azusd ' > /dev/null; then
                echo -e "${RED}Can't stop azusd ! Reboot and try again...${NC} \a"
                exit 2
            fi
        fi
    fi
}


echo "Your AZUS Masternode Will be Updated To The Latest Version v1.1.0 Now" 
sudo apt-get -y install unzip

#remove crontab entry to prevent daemon from starting
crontab -l | grep -v 'azusauto.sh' | crontab -

#Stop azusd  by calling the stop_daemon function
stop_daemon

rm -rf /usr/local/bin/azus*
mkdir AZUS_1.1.0
cd AZUS_1.1.0
wget https://github.com/AzusNodes/AZUS-MNScript/releases/download/v1.1.0/azus-1.1.0-ubuntu-16.04-daemon.tar.gz
tar -xzvf azus-1.1.0-ubuntu-16.04-daemon.tar.gz
mv azusd  /usr/local/bin/azusd 
mv azusd-cli /usr/local/bin/azusd-cli
chmod +x /usr/local/bin/azus*
rm -rf ~/.azus/blocks
rm -rf ~/.azus/chainstate
rm -rf ~/.azus/sporkssporks
rm -rf ~/.azus/zerocoin
rm -rf ~/.azus/peers.dat
cd ~/.azus/
wget https://github.com/AzusNodes/AZUS-MNScript/releases/download/v1.1.0/bootstrap.zip
unzip bootstrap.zip

cd ..
rm -rf ~/.azus/bootstrap.zip ~/AZUS_1.1.0

# add new nodes to config file
sed -i '/addnode/d' ~/.azus/azus.conf

echo "addnode=167.99.138.17
addnode=104.248.85.5
addnode=167.172.43.112
addnode=188.166.63.147
addnode=64.227.76.85
addnode=134.122.59.8" >> ~/.azus/azus.conf

#start azusd 
azusd  -daemon

printf '#!/bin/bash\nif [ ! -f "~/.azus/azusd .pid" ]; then /usr/local/bin/azusd  -daemon ; fi' > /root/azusauto.sh
chmod -R 755 /root/azusauto.sh
#Setting auto start cron job for AZUS
if ! crontab -l | grep "azusauto.sh"; then
    (crontab -l ; echo "*/5 * * * * /root/azusauto.sh")| crontab -
fi

echo "Masternode Updated!"
echo "Please wait a few minutes and start your Masternode again on your Local Wallet"