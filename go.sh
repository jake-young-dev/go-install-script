#!/bin/bash

echo "Starting Golang install"

#validate version and architecture
echo "Parsing go version"
#looking for go version in go.mod file, only checking up to minor version ignoring patch value to allow for stable versions
# -P uses perl syntax
DL_VERSION_RAW="$(grep "^go [0-9]+.[0-9]+" go.mod -P)"
if [[ -z "$DL_VERSION_RAW" ]]; then
  echo "FATAL: Unable to pull version from go.mod"
  exit 1
fi
echo "Found go version: ${DL_VERSION_RAW}"

#checking for required input
#"." is default arch value meaning required field was not set
if [[ "$GO_INSTALL_ARCH" == "." ]]; then
  echo "FATAL: Missing required Linux archictecture parameter"
  exit 1
fi
DL_ARCH=$GO_INSTALL_ARCH
DL_VSPL=( $DL_VERSION_RAW )
DL_VERSION="${DL_VSPL[1]}"

#ensure we have patch-level version, if not add 0 for stable releases
# -P uses perl syntax
DL_VERSION_PAD_CHECK="$(grep "^go [0-9]+.[0-9]+.[0-9]+" go.mod -P)"
if [[ -z "$DL_VERSION_PAD_CHECK" ]]; then
  DL_VERSION="$DL_VERSION"".0"
  echo "Fixing version number to ${DL_VERSION}"
fi

echo "Checking if go is already installed"
#check if go is already present before starting install process and delete files if purge input is set
# -v writes string that indicates command or command path to output, prevents command not found error
GO_CHECK=$(command -v go)
if [[ "$GO_CHECK" ]]; then
  #if purge flag is set remove old go files
  if [[ "$GO_INSTALL_PURGE" == "yes" ]]; then
    echo "Removing old go versions"
    sudo rm -r /usr/bin/go 
    sudo rm -r /usr/bin/gofmt
  else
    echo "FATAL: Go is already installed, set purge to 'yes' if you wish to update installed version"
    exit 1
  fi
fi
echo "Ready for install"

echo "Downloading go files for ${DL_VERSION}/${DL_ARCH}"
PATH_FOR_FILES=/usr/local/go
PATH_FOR_TAR=/usr/local
sudo mkdir -v -m 0777 -p "$PATH_FOR_FILES"

#wget
# -q quiets output
# O- outputs file data to pipe instead of file
#tar
# -z use gzip
# -x extract files
# -f extract from "file"
# - extract from pipe as a file
# -C change to GOPATH directory
if sudo wget -qO- "https://golang.org/dl/go${DL_VERSION}.linux-${DL_ARCH}.tar.gz" | sudo tar -zxf - -C "$PATH_FOR_TAR"; then
  echo "Files downloaded"
else
  echo "FATAL: Unable to download and extract files"
fi

echo "Setting path for go command"
export PATH=$PATH:$PATH_FOR_FILES/bin
echo "$PATH_FOR_FILES/bin" >> "$GITHUB_PATH" #set action path too

#grab go version to test the go command
GLOBAL_GO_CMD_VERSION=$(go version)
if [[ -z "$GLOBAL_GO_CMD_VERSION" ]]; then
  echo "FATAL: Failed to register go command"
  exit 1
else
  echo "Go command setup for ${GLOBAL_GO_CMD_VERSION}"
fi

#adding GOPATH to path to support go commands
echo "Setting path to allow for commands installed by go"
GP=$(go env GOPATH)/bin
export PATH=$PATH:$GP
echo "$GP" >> "$GITHUB_PATH"

#if commands input is set pull the input and install them all using 'go install'
if [[ "$GO_INSTALL_COMMANDS" != "." ]]; then # "." is used as a default
  #allows for multiple cmds using |
  INPUT_ARR=( $GO_INSTALL_COMMANDS )
  for i in "${INPUT_ARR[@]}"; do
      echo "Installing go command from ${i}"
      if go install ${i}; then
        echo "Command setup for ${i}"
      else
        echo "FATAL: Unable to install ${i} with go"
        exit 1
      fi
  done
fi
