# go-install-script
[![tests](https://github.com/jake-young-dev/go-install-script/actions/workflows/test.yaml/badge.svg?branch=master)](https://github.com/jake-young-dev/go-install-script/actions/workflows/test.yaml)
<br />

A simple, hacky github action to install golang and golang commands on linux hosts. This provides the ability to install and setup golang without node/typescript which is required when using [actions/setup-go](https://github.com/actions/setup-go). 


## Usage
The workflow file contains a good [example](https://github.com/jake-young-dev/go-install-script/blob/master/.github/workflows/test.yaml#L20). I recommend using a tagged release to avoid unexpected changes that may come to the master branch, there may be breaking changes until v1.0.0
#### Go verions
Go version is determined using the go.mod file in the root of working directory. Go files are pulled directly from the go download [site](https://go.dev/dl/) and all go commands are installed using 'go install'
#### Inputs
Some command arguments are required for this script to run and are supplied as inputs to the action. <br />
- [architecture] Required, the CPU architecture for the go files data pull
- [purge] Optional, (yes|no) Remove previously installed go versions
    - the purge input will remove any previous go files if set to yes any non-yes inputs will not delete previous go versions and a fatal error is thrown if go is already installed
- [commands] Optional, commands to be installed using 'go install'
    - links must contain a version and must be in a public repository
#### Testing
A simple testing job is triggered on a push to the master branch, the job will create a mock go.mod file to ensure that one is present in testing container

<br />

## Issues
This repo is a as brain-dead as I could make it and is intended to be as fast and low-level as possible. The code is loosely based off of the go tool script from [catthehacker](https://github.com/catthehacker/docker_images/blob/master/linux/ubuntu/scripts/go.sh) but we have strayed pretty far from that. Please open an issue for any problems or suggestions.
