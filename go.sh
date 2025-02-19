#!/bin/bash

printf "Installing Golang\n"

DL_VER="1.23.5"
DL_ARCH="amd64"
GOPATH="${ACT_TOOLSDIRECTORY}/go/${DL_VER}/${DL_ARCH}"
mkdir -v -m 0777 -p "$GOPATH"
wget -qO- "https://golang.org/dl/go${DL_VER}.linux-${DL_ARCH}.tar.gz" | tar -zxf - --strip-components=1 -C "$GOPATH"
"$GOPATH/bin/go" version
ln -s "$GOPATH/bin"/* /usr/bin

printf "\nInstalled Golang\n"