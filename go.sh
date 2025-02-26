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

sudo mkdir -v -m 0777 -p /usr/local/go
sudo wget -qO- "https://golang.org/dl/go${DL_VERSION}.linux-${DL_ARCH}.tar.gz" | sudo tar -zxf - -C /usr/local
export PATH=$PATH:/usr/local/go/bin
echo "/usr/local/go/bin" >> "$GITHUB_PATH"

#grab go version using go command
GLOBAL_GO_CMD_VERSION=$(go version)
if [[ -z "$GLOBAL_GO_CMD_VERSION" ]]; then
  echo "FATAL: Failed to register go command"
  exit 1
fi

GP=$(go env GOPATH)/bin
export PATH=$PATH:$GP
echo "$GP" >> "$GITHUB_PATH"

if [[ "$GO_INSTALL_COMMANDS" != "." ]]; then
  INPUT_ARR=( $GO_INSTALL_COMMANDS )
  for i in "${INPUT_ARR[@]}"; do
      echo "Installing go command from ${i}"
      go install ${i}
  done
fi
