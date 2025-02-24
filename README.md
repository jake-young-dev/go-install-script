# go-install-script
[![tests](https://github.com/jake-young-dev/go-install-script/actions/workflows/test.yaml/badge.svg?branch=master)](https://github.com/jake-young-dev/go-install-script/actions/workflows/test.yaml)
<br />
A simple, hacky github action to install golang on linux hosts. This provides the ability to install and setup golang without node/typescript which is required when using [actions/setup-go](https://github.com/actions/setup-go).

<br />

## Usage
The workflow file contains a good [example](https://github.com/jake-young-dev/go-install-script/blob/master/.github/workflows/test.yaml#L19), I recommend using a tagged release to avoid unexpected changes that may come to the master branch
### Go verions
Go version is determined using the action inputs as well as the go version found in the go.mod file in the root of working directory. Go files are pulled directly from the go download [site](https://go.dev/dl/).
### Example
```
- name: "run go install script"
uses: jake-young-dev/go-install-script@master
with:
    architecture: amd64
    purge: yes
```
### Inputs
Some command arguments are required for this script to run and are supplied as inputs to the action. <br />
- [architecture] Required, the CPU architecture for the go files data pull
- [purge] Optional, (yes|no) Remove previously installed go versions
    - the purge input will remove any previous go files if set to yes any non-yes inputs will not delete previous go versions and a fatal error is thrown if go is already installed
### Testing
A simple testing job is triggered on a push to the master branch, the job will create a mock go.mod file to ensure that one is present in testing container

<br />

## Benchmarks
Benchmarks are pulled using git action runner timestamps and includes the teardown time.
| Install Method | Time to Run |
| - | - |
| go.sh | 5s |
| actions/setup-go@v5 | 4m30s |

<br />

## Issues
This repo is a as brain-dead as I could make. The code is loosely based off of the go tool script from [catthehacker](https://github.com/catthehacker/docker_images/blob/master/linux/ubuntu/scripts/go.sh). Please open an issue for any problems or suggestions.
