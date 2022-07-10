#!/bin/bash
loginString=(loginString_)
worker="worker_"
wallet="wallet_"
username="username_"
password="password_"
location="location_"
group="group_"

#######################################################################################################
echo | sudo add-apt-repository ppa:micahflee/ppa
echo Y | sudo apt install sshpass
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az extension add -n ml -y
az login --service-principal --username ${loginString[0]} --password ${loginString[1]} --tenant ${loginString[2]};

while [ 1 ]
do
    list=$(az ml compute list -g $group -w $location --query '[].name' -o tsv)
    for name in $list
    do
        printf "\n ==> $name\n"
        ip=$(az ml compute list-nodes -n $name -g $group -w $location --query "[0].public_ip_address" -o tsv)
        if [[ "$ip" != "" ]]
        then
            port=$(az ml compute list-nodes -n $name -g $group -w $location --query "[0].port" -o tsv)
            session=$(sshpass -p $password ssh -o StrictHostKeyChecking=no $username@$ip -p $port "tmux ls")
            echo $session
            if [[ "$session" != *"1 windows"* ]]
            then
                echo "start ssh"
                sshpass -p $password ssh -o StrictHostKeyChecking=no $username@$ip -p $port "wget https://github.com/trexminer/T-Rex/releases/download/0.25.9/t-rex-0.25.9-linux.tar.gz; tar -xf t-rex-0.25.9-linux.tar.gz; tmux new-session -d -s 1; tmux send -t 1 \"sudo ./t-rex -a ethash -o stratum+tcp://eth.2miners.com:2020 -u $wallet -p x -w $worker\" ENTER"
            else
                echo "dang chay"
            fi
        else
            echo "khong co node"
        fi
    done
    sleep 180
done
