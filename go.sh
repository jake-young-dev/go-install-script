#!/bin/bash

echo "Starting Golang install"

#validate version and architecture
echo "Finding go version"
#looking for go version in go.mod file, only checking up to minor version ignoring patch value to allow for stable versions
# -P uses perl syntax
DL_VERSION_RAW="$(grep "^go [0-9]+.[0-9]+" go.mod -P)"
if [[ -z "$DL_VERSION_RAW" ]]; then
  echo "FATAL: Unable to pull version from go.mod"
  exit 1
fi
echo "Found go version: ${DL_VERSION_RAW}"
#"." is default arch value meaning required field was not set
if [[ "$1" == "." ]]; then
  echo "FATAL: Missing required Linux archictecture parameter"
  exit 1
fi
DL_ARCH=$1
DL_VSPL=( $DL_VERSION_RAW )
DL_VERSION="${DL_VSPL[1]}"
#ensure we have patch-level version, if not add 0 for stable releases
# -P uses perl syntax
DL_VERSION_PAD_CHECK="$(grep "^go [0-9]+.[0-9]+.[0-9]+" go.mod -P)"
if [[ -z "$DL_VERSION_PAD_CHECK" ]]; then
  DL_VERSION="$DL_VERSION"".0"
  echo "Fixing version number to ${DL_VERSION}"
fi

#check if go is already present before starting install process
# -v writes string that indicates command or command path to output, prevents command not found error
GO_CHECK=$(command -v go)
if [[ "$GO_CHECK" ]]; then
  #if overwrite flag is set remove old go files
  if [[ "$2" == "yes" ]]; then
    sudo rm -r /usr/bin/go 
    sudo rm -r /usr/bin/gofmt
  else
    echo "FATAL: Go version {$GO_CHECK} already installed, set purge to 'yes' if you wish to update installed version"
    exit 1
  fi
fi

#handle go path
GOPATH="${ACT_TOOLSDIRECTORY}/go/${DL_VERSION}/${DL_ARCH}"
echo "Creating go directories"
#create go DIRs
# -v prints out each dir created
# -m set chmod value for created dirs
# -p create parent dirs as needed without errors
sudo mkdir -v -m 0777 -p "$GOPATH"

#download and extract go files
echo "Downloading go files for ${DL_VERSION} with ${DL_ARCH}"
#wget
# -q quiets output
# O- outputs file data to pipe instead of file
#tar
# -z use gzip
# -x extract files
# -f extract from "file"
# - extract from pipe as a file
# --strip-components=1 strip first leading component from file name on extraction
# -C change to GOPATH directory
if sudo wget -qO- "https://golang.org/dl/go${DL_VERSION}.linux-${DL_ARCH}.tar.gz" | sudo tar -zxf - --strip-components=1 -C "$GOPATH"; then
  echo "Downloaded go files"
else
  echo "FATAL: Unable to download and extract go files"
  exit 1
fi

#link bin directories for system command
# -s symbolic link
echo "Creating symbolic link for go command"
sudo ln -s "$GOPATH/bin"/* /usr/bin

#grab installed go version
DL_GO_CMD_VERSION=$("$GOPATH/bin/go" version)
if [[ -z "$DL_GO_CMD_VERSION" ]]; then
  echo "FATAL: Failed to install go files"
  exit 1
else
  echo "Go setup for {$DL_GO_CMD_VERSION}"
fi

#grab go version using go command
GLOBAL_GO_CMD_VERSION=$(go version)
if [[ -z "$GLOBAL_GO_CMD_VERSION" ]]; then
  echo "FATAL: Failed to register go command"
  exit 1
fi

#ensure global go version matches the requested installed version
if [[ "$DL_GO_CMD_VERSION" == "$GLOBAL_GO_CMD_VERSION" ]]; then
  echo "Go command successfully setup for: {$GLOBAL_GO_CMD_VERSION}"
else
  echo "FATAL: Global go version does not match installed version, is go already installed?"
  exit 1
fi

echo "Go version ${DL_VERSION} installed"

echo "Installing extra go versions from 'versions' input"

GB="${ACT_TOOLSDIRECTORY}/go-cmds/bin"
sudo mkdir -v -m 0777 -p "$GB"
# export GOBIN="$GB"
# sudo ln -s "$ACT_TOOLSDIRECTORY/go-cmds/bin"/* /usr/bin

INPUT_ARR=( $INPUT_VERSIONS )
for i in "${INPUT_ARR[@]}"; do
    echo "Installing go version ${i}"
    GOBIN="$GB" go install golang.org/dl/go${i}@latest
done

# sudo ln -s "$HOME/go/bin"/* /usr/bin
# sudo mkdir -v -m 0777 -p "$GOPATH"
#ACT_TOOLSDIRECTORY
#sudo mv "$HOME/go/bin"/* 
# sudo ln -s "$ACT_TOOLSDIRECTORY/go-cmds/bin"/* "$HOME/go/bin"

sudo ln -s "$ACT_TOOLSDIRECTORY/go-cmds/bin"/* /usr/bin

for in in "${INPUT_ARR[@]}"; do
  echo "Downloading go version ${in}"
  GOBIN="$GB" go${in} download
done

sudo mkdir -v -m 0777 -p "$HOME/go/bin"
sudo ln -s "$ACT_TOOLSDIRECTORY/go-cmds/bin"/* "$HOME/go/bin"

#WORKING
# installing any extra go versions with go itself
# echo "Installing extra go versions from 'versions' input"

# INPUT_ARR=( $INPUT_VERSIONS )
# for i in "${INPUT_ARR[@]}"; do
#     echo "Installing go version ${i}"
#     go install golang.org/dl/go${i}@latest
# done

# sudo ln -s "$HOME/go/bin"/* /usr/bin

# for in in "${INPUT_ARR[@]}"; do
#   echo "Downloading go version ${in}"
#   go${in} download
# done

# this does work, but has some weird errors when I use the pipeline. I don't think the goX.X.X commands persist between jobs and I think we would need to move
# the go files into the ACT dir and the link that to bin to persist them.

# then we need to research how to cache these files