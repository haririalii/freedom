#!/bin/bash

SS_DIR=/opt/shadowsocks
SS_CONFIG=$SS_DIR/conf.json

DEFAULT__SS_CIPHER=aes-256-gcm
DEFAULT__SS_SERVER_ADDR=0.0.0.0
DEFAULT__SS_PORT=443
DEFAULT__SS_PASSWORD=75dI6Riw

CIPHERS=(
aes-256-gcm
aes-192-gcm
aes-128-gcm
aes-256-ctr
aes-192-ctr
aes-128-ctr
aes-256-cfb
aes-192-cfb
aes-128-cfb
camellia-128-cfb
camellia-192-cfb
camellia-256-cfb
chacha20-ietf-poly1305
chacha20-ietf
chacha20
rc4-md5
)

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# check and install ss-server
if ! command -v ss-server &> /dev/null 
then
	echo "Update apt repository"
	apt -y update
    	echo "\"ss-server\" could not be found, so it's going to install"
    	apt -y install shadowsocks-libev
else
     	echo "\"ss-server\" already exist."	
fi


# create working directory
if [ ! -d "$SS_DIR" ]; then
	echo "Creating working dir ..."
	mkdir -p $SS_DIR
fi

echo
echo "Working directory: $SS_DIR"
echo


# server address
read -p "Please enter your server address [$DEFAULT__SS_SERVER_ADDR]: " SS_SERVER_ADDR
SS_SERVER_ADDR=${SS_SERVER_ADDR:-$DEFAULT__SS_SERVER_ADDR}


# cipher
echo "Please select stream cipher:"
echo "Supported chipers:"
for CIPHER in "${CIPHERS[@]}" 
do
	echo -e "\t$CIPHER"
done

echo

# select cipher
while true
do
	read -p "Which cipher you'd select [$DEFAULT__SS_CIPHER]: " SS_CIPHER

	if [ -z "$SS_CIPHER" ] # use default cipher if input is empty
	then 
		SS_CIPHER=$DEFAULT__SS_CIPHER
		break
	elif [[ " ${CIPHERS[*]} " =~ " ${SS_CIPHER} " ]]; then # check input cipher with supported ciphers
		break # brake if cipher exist in the supported ciphers
	else
		echo
		echo "Invalid cipher: \"$SS_CIPHER\""
		echo
	fi
done


# port
while true
do
	read -p "Please enter server port [$DEFAULT__SS_PORT]: " SS_PORT
	if [ -z "$SS_PORT" ] # use default port if input is empty
	then
		SS_PORT=$DEFAULT__SS_PORT
		break
	elif [ "$SS_PORT" -lt 0 ] || [ "$SS_PORT" -gt 65535 ]
        then
		echo
                echo "\"$SS_PORT\" is invalid it must be between [1-65535]!"
		echo

	elif [[ $(lsof -i:"$SS_PORT" | grep LISTEN) ]] &> /dev/null
	then
		echo
                echo "\"$SS_PORT\" is already in use!"
                echo

	else
		break
	fi
done


# password
read -p "Please enter your server password [$DEFAULT__SS_PASSWORD]: " SS_PASSWORD
SS_PASSWORD=${SS_PASSWORD:-$DEFAULT__SS_PASSWORD}


#V2-RAY plugin
echo
echo "Install v2ray-plugin..."
echo
# install v2ray
set -e
./v2ray.sh $SS_DIR

# configuration file
if test -f "$SS_CONFIG"; then
	echo
	while true; do
    		read -p "Config file already exist [$SS_CONFIG], do you want to overwrite it? (Y/N): " yn
    		case $yn in
        		[Yy]* ) break;;
        		[Nn]* ) exit 1;;
        		* ) echo "Please answer yes or no.";;
    		esac
	done

fi

echo


# create config file

if ! command -v jq &> /dev/null
then
        echo "Install jq for create json file"
        apt -y install jq
fi


jq -n \
    --arg server "$SS_SERVER_ADDR" \
    --arg server_port "$SS_PORT" \
    --arg local_port "$SS_PORT" \
    --arg password "$SS_PASSWORD" \
    --arg method "$SS_CIPHER" \
    --arg timeout 300 \
    --arg user "nobody" \
    --arg plugin "v2ray-plugin" \
    --arg plugin_opts "server"  \
    '{server: $server, server_port: ($server_port|tonumber), local_port: ($local_port|tonumber), password: $password, method: $method, timeout: ($timeout|tonumber), user: $user, plugin : $plugin, plugin_opts: $plugin_opts}' > $SS_CONFIG


echo "Server config ($SS_CONFIG):"
cat $SS_CONFIG
echo

echo "Now you can start shadowsocks server using following command: "
echo "################################################################"
echo -e "\t ss-server -c $SS_CONFIG start"
echo "################################################################"
