#!/bin/bash

# Pull mattermost folder from ugent
echo "Pulling mattermost folder from UGent server"
rsync -avz --no-owner --no-group --chmod=Du=rwx,Dgo=rx,Fu=rw,Fgo=r --rsync-path="sudo rsync" -e "ssh -J proxy@bastion2.slices-be.eu" ubuntu@10.10.216.198:~/mattermost ~

# Sync mattermost with pve lxc container
echo "Syncing mattermost folder with pve lxc container"
rsync -avz --no-owner --no-group --chmod=Du=rwx,Dgo=rx,Fu=rw,Fgo=r ~/mattermost root@192.168.129.70:~
