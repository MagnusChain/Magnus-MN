#!/bin/bash

#stop_daemon function
function stop_daemon {
    if pgrep -x 'magnusd' > /dev/null; then
        echo -e "${YELLOW}Attempting to stop magnusd${NC}"
        magnus-cli stop
        sleep 30
        if pgrep -x 'magnusd' > /dev/null; then
            echo -e "${RED}magnusd daemon is still running!${NC} \a"
            echo -e "${RED}Attempting to kill...${NC}"
            sudo pkill -9 magnusd
            sleep 30
            if pgrep -x 'magnusd' > /dev/null; then
                echo -e "${RED}Can't stop magnusd! Reboot and try again...${NC} \a"
                exit 2
            fi
        fi
    fi
}


echo "Your MAGNUS Masternode Will be Updated To The Latest Version v1.1.0 Now" 
sudo apt-get -y install unzip

#remove crontab entry to prevent daemon from starting
crontab -l | grep -v 'magnusauto.sh' | crontab -

#Stop magnusd by calling the stop_daemon function
stop_daemon

rm -rf /usr/local/bin/magnus*
mkdir MAG_1.1.0
cd MAG_1.1.0
wget https://github.com/MagnusChain/Magnus/releases/download/v1.1.0/Magnus-1.1.0-ubuntu-daemon.tar.gz
tar -xzvf Magnus-1.1.0-ubuntu-daemon.tar.gz
mv magnusd /usr/local/bin/magnusd
mv magnus-cli /usr/local/bin/magnus-cli
chmod +x /usr/local/bin/magnus*
rm -rf ~/.magnus/blocks
rm -rf ~/.magnus/chainstate
rm -rf ~/.magnus/sporks
rm -rf ~/.magnus/evodb
rm -rf ~/.magnus/peers.dat
cd ~/.magnus/
wget https://github.com/MagnusChain/Magnus/releases/download/v1.1.0/bootstrap.zip
unzip bootstrap.zip

cd ..
rm -rf ~/.magnus/bootstrap.zip ~/MAG_1.1.0

# add new nodes to config file
sed -i '/addnode/d' ~/.magnus/magnus.conf

echo "addnode=170.64.138.178
addnode=170.64.183.45
addnode=170.64.183.44
addnode=170.64.183.61
addnode=170.64.183.60
addnode=170.64.183.59" >> ~/.magnus/magnus.conf

#start magnusd
magnusd -daemon

printf '#!/bin/bash\nif [ ! -f "~/.magnus/magnus.pid" ]; then /usr/local/bin/magnusd -daemon ; fi' > /root/magnusauto.sh
chmod -R 755 /root/magnusauto.sh
#Setting auto start cron job for MAGNUS
if ! crontab -l | grep "magnusauto.sh"; then
    (crontab -l ; echo "*/5 * * * * /root/magnusauto.sh")| crontab -
fi

echo "Masternode Updated!"
echo "Please wait a few minutes and start your Masternode again on your Local Wallet"