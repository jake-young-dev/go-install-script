#!/bin/bash

echo "Installing Golang"
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Script requires version and architecture arguments (e.g. ./go.sh 1.23.5 amd64)"
  exit 1
fi

DL_VER=$1
DL_ARCH=$2
GOPATH="${ACT_TOOLSDIRECTORY}/go/${DL_VER}/${DL_ARCH}"
mkdir -v -m 0777 -p "$GOPATH"
wget -qO- "https://golang.org/dl/go${DL_VER}.linux-${DL_ARCH}.tar.gz" | tar -zxf - --strip-components=1 -C "$GOPATH"
"$GOPATH/bin/go" version
ln -s "$GOPATH/bin"/* /usr/bin

echo "Installed"
