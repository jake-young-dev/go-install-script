#!/bin/bash

echo "Starting Golang install"

#validate version and architecture
echo "Finding go version"
DL_VERSION_RAW="$(grep "^go [0-9]+.[0-9]+.[0-9]+" go.mod -oP)"
if [[ -z "$DL_VERSION_RAW" ]]; then
  echo "FATAL: Unable to pull version from go.mod"
  exit 1
fi
echo "Found go version: ${DL_VERSION_RAW}"
if [[ -z "$1" ]]; then
  echo "FATAL: Missing required Linux archictecture parameter"
  exit 1
fi
DL_ARCH=$1
DL_VSPL=( $DL_VERSION_RAW )
DL_VERSION="${DL_VSPL[1]}"

#handle go path
GOPATH="${ACT_TOOLSDIRECTORY}/go/${DL_VERSION}/${DL_ARCH}"
echo "Creating GOPATH directories"
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

#check for go version
if OUTPUT=$("$GOPATH/bin/go" version); then
  echo "Setup successful for: {$OUTPUT}"
else
  echo "FATAL: Failed to extract go files to system"
  exit 1
fi

#link bin directories for system command
echo "Creating symbolic link for go command"
sudo ln -s "$GOPATH/bin"/* /usr/bin

#check for go version
if OUTPUT=$(go version); then
  echo "Command setup successful for: {$OUTPUT}"
else
  echo "FATAL: Failed to create link for go command"
  exit 1
fi

echo "Golang successfully installed"
