#!/bin/bash
GO_COMPILER_FILENAME=go1.16.linux-amd64.tar.gz
PROJECT_GIT_NAME=v2ray-plugin
PROJECT_GIT_ADDR=https://github.com/shadowsocks/v2ray-plugin.git
GO_COMPILE_ADDR=https://dl.google.com/go/$GO_COMPILER_FILENAME

APP_NAME=v2ray-plugin

SS_DIR=$1
V2R_DIR=$SS_DIR/v2ray-plugin
GO=go

# check root access
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# check input arguments
if [ $# -eq 0 ]
then
	echo "No arguments supplied [Working directory]"
	exit 1
fi

# create working directory
if [ ! -n $V2R_DIR ]
then
	echo "Create working directory [$V2R_DIR]"
	mkdir -p $V2R_DIR
fi
echo
echo "Working dir [$V2R_DIR]"
echo


# go to working directory
cd $V2R_DIR


# clone project from git repository
if [ ! -n $PROJECT_GIT_NAME ]
then
	echo "Clone project [$PROJECT_GIT_ADDR] ..."
	git clone $PROJECT_GIT_ADDR
else
        echo
	echo "Project already exist[$PROJECT_GIT_NAME]!"
	echo
fi


# install go compiler
if ! command -v $GO &> /dev/null #check for go compiler existence
then
	# download go compiler
    	echo "Download go compiler [$GO_COMPILE_ADDR]..."
	set -e
    	wget $GO_COMPILE_ADDR
    	tar -xvzf $GO_COMPILER_FILENAME
	GO=$V2R_DIR/go/bin/go
fi

# build project
cd $V2R_DIR/$PROJECT_GIT_NAME
echo
echo "Build project..."
$GO build

echo
echo "Copy executable file to [/usr/bin/v2ray-plugin]"
cp v2ray-plugin /usr/bin/v2ray-plugin

echo
echo "Run [setcap cap_net_bind_service+ep /usr/bin/v2ray-plugin]"
setcap cap_net_bind_service+ep /usr/bin/v2ray-plugin
