DEV="wlan0"
IP="10.86.84.10/22"
echo "The ip $IP will be added to the device $DEV"
read -r -p "Proceed? Y/n:" res
while [[ -n res && "${res,,}" != "y" && "${res,,}" != "n" ]]; do
	read -r -p "Proceed? Y/n:" res
done
if [[ $res == "n" ]]; then
	echo "Exiting..."
	exit 1
fi
sudo ip addr add "${IP}" dev "${DEV}"
