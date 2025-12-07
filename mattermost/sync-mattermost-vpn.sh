#!/bin/bash

# This script will rsync the Mattermost instance on Borluutstraat servers with the instance on UGent servers
# For use not in the Borluutstraat LAN through VPN.

if pgrep tailscaled &>/dev/null; then
	echo "Tailscaled is running, continue...";
else 
	echo "Tailscaled not running, exiting...";
	exit 1;
fi

# Pull mattermost folder from ugent
generate_dirname() {
	DIR_NAME="${HOME}/mattermost-$(date -I)-$(uuidgen | cut -d- -f1)"
}
generate_dirname;
while [[ -d "${DIR_NAME}" ]]; do
	echo "Dir ${DIR_NAME} exists, regenerating..."
	generate_dirname;
done
echo "Pulling mattermost folder from UGent server to local dir ${DIR_NAME}"
rsync -avz --no-owner --no-group --chmod=Du=rwx,Dgo=rx,Fu=rw,Fgo=r --rsync-path="sudo rsync" -e "ssh -J proxy@bastion2.slices-be.eu" ubuntu@10.10.216.198:~/mattermost/ "${DIR_NAME}"

SSH_PROXY_HOST="nekros-server"
MATTERMOST_HOST="192.168.129.70"

# Sync mattermost with pve lxc container
echo "Syncing mattermost folder with pve lxc container"
echo "Using proxy ${SSH_PROXY_HOST} for host ${MATTERMOST_HOST}";
rsync -avz --no-owner --no-group --chmod=Du=rwx,Dgo=rx,Fu=rw,Fgo=r "${DIR_NAME}/" -e "ssh -J nekros@${SSH_PROXY_HOST}" root@"${MATTERMOST_HOST}":~/mattermost
echo "Done"
echo 
read_input() {
	read -r -p "Delete local copy ${DIR_NAME}? Y\n:" res;
}
read_input;
while [[ -n "${res}" && "${res,,}" != "y" && "${res,,}" != "n" ]]; do
	read_input;
done
if [[ "${res,,}" != "n" ]]; then
	echo "Deleting ${DIR_NAME}..."
	rm -r "${DIR_NAME}"
fi
echo "Done"
exit 0;
