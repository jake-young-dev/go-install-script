#!/bin/bash

#todo:
# remove downloaded file after install
# remove sym link and actually move the files to /usr/bin
# move to using go to install MORE go versions and allow for many

echo "Starting Golang install"

#validate version and architecture
echo "Finding go version"
#looking for go version in go.mod file, only checking up to minor version ignoring patch value to allow for stable versions like 1.24
# -P uses perl syntax
DL_VERSION_RAW="$(grep "^go [0-9]+.[0-9]+" go.mod -P)"
if [[ -z "$DL_VERSION_RAW" ]]; then
  echo "FATAL: Unable to pull go version from go.mod"
  exit 1
fi
echo "Found go version: ${DL_VERSION_RAW}"
#"." is default arch value meaning required field was not set
if [[ "$1" == "." ]]; then
  echo "FATAL: Missing archictecture parameter"
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
  echo "Fixing version number to: ${DL_VERSION}"
fi

#check if go is already present before starting install process, if purge input is set to "yes" we remove them, otherwise
#a fatal error is thrown
# -v writes string that indicates command or command path to output, prevents command not found error from using go version
GO_CHECK=$(command -v go)
if [[ "$GO_CHECK" ]]; then
  #if overwrite flag is set remove old go files
  if [[ "$2" == "yes" ]]; then
    echo "Removing previous go version {$GO_CHECK}"
    sudo rm -r /usr/bin/go 
    sudo rm -r /usr/bin/gofmt
  else
    echo "FATAL: Go version {$GO_CHECK} already installed, set purge input to 'yes' to remove {$GO_CHECK} and install {$DL_VERSION}"
    exit 1
  fi
fi

#starting new work here
echo "Creating GOPATH directories"

GOPATH="${ACT_TOOLSDIRECTORY}/go"
sudo mkdir -v -m 0777 -p "$GOPATH"
# sudo mkdir -v -m 0777 -p /usr/local/go

echo "Downloading go files for ${DL_VERSION} ${DL_ARCH}"

#no longer stripping path
if sudo wget -qO- "https://golang.org/dl/go${DL_VERSION}.linux-${DL_ARCH}.tar.gz" | sudo tar -zxf - --strip-components=1 -C "$GOPATH"; then
  echo "Downloaded go files"
else
  echo "FATAL: Unable to download and extract go files"
  exit 1
fi

ls ${GOPATH}

# echo "Moving go files" # keep linking for caching
# sudo ln -s "${GO_PATH}/${DL_VERSION}/${DL_ARCH}/bin/*" /usr/bin
# sudo ln -s "${GO_PATH}"/* /usr/local/go
echo "Testing here"
export PATH="$GOPATH/bin:$PATH"

GLOBAL_GO_CMD_VERSION=$(go version)
if [[ -z "$GLOBAL_GO_CMD_VERSION" ]]; then
  echo "FATAL: Failed to register go command"
  exit 1
fi

#handle go path
# GOPATH="${ACT_TOOLSDIRECTORY}/go/${DL_VERSION}/${DL_ARCH}"
# echo "Creating GOPATH directories"
#create go DIRs
# -v prints out each dir created
# -m set chmod value for created dirs
# -p create parent dirs as needed without errors
# sudo mkdir -v -m 0777 -p "$GOPATH"

#download and extract go files
# echo "Downloading go files for ${DL_VERSION} ${DL_ARCH}"
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
# if sudo wget -qO- "https://golang.org/dl/go${DL_VERSION}.linux-${DL_ARCH}.tar.gz" | sudo tar -zxf - --strip-components=1 -C "$GOPATH"; then
#   echo "Downloaded go files"
# else
#   echo "FATAL: Unable to download and extract go files"
#   exit 1
# fi

# ls -la

#link bin directories for system command
# -s symbolic link
# echo "Creating symbolic link for go command"
# sudo ln -s "$GOPATH/bin"/* /usr/bin
# echo "Moving go files"
# sudo ln -s "${ACT_TOOLSDIRECTORY}/go"/* /usr/bin/go
# sudo cp -r "${ACT_TOOLSDIRECTORY}/go"/* /usr/bin/go
# sudo mv "${ACT_TOOLSDIRECTORY}/go/"/* /usr/bin/go

#grab installed go version
# DL_GO_CMD_VERSION=$("$GOPATH/bin/go" version)
# if [[ -z "$DL_GO_CMD_VERSION" ]]; then
#   echo "FATAL: Failed to install go files"
#   exit 1
# else
#   echo "Go setup for {$DL_GO_CMD_VERSION}"
# fi

# #grab go version using go command
# GLOBAL_GO_CMD_VERSION=$(go version)
# if [[ -z "$GLOBAL_GO_CMD_VERSION" ]]; then
#   echo "FATAL: Failed to register go command"
#   exit 1
# fi

# #ensure global go version matches the requested installed version
# if [[ "$DL_GO_CMD_VERSION" == "$GLOBAL_GO_CMD_VERSION" ]]; then
#   echo "Go command successfully setup for: {$GLOBAL_GO_CMD_VERSION}"
# else
#   echo "FATAL: Global go version does not match installed version, is go already installed?"
#   exit 1
# fi

echo "Golang successfully installed"

# go install golang.org/dl/go1.22.1@latest

# go1.22.1 download
# go1.22.1 version

# ls ${ACT_TOOLSDIRECTORY}/go -la
# ls /usr/bin/go -l