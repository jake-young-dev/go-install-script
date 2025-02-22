# go-install-script
[![tests](https://github.com/jake-young-dev/go-install-script/actions/workflows/test.yaml/badge.svg?branch=master)](https://github.com/jake-young-dev/go-install-script/actions/workflows/test.yaml)
<br />
A simple, hacky github action to install golang on linux hosts. This provides the ability to install and setup golang without node/typescript which is required when using [actions/setup-go](https://github.com/actions/setup-go). Golang files are pulled directly from the go download [site](https://go.dev/dl/) and are based on the go version in the go.mod file in the root of the project. The architecture string must be supplied as a command-line argument for the script (e.g ./go.sh amd64)

<br />

# Benchmarks
Benchmarks are pulled using git action runner timestamps and includes the teardown time.
| Install Method | Time to Run |
| - | - |
| go.sh | 5s |
| actions/setup-go@v5 | 4m30s |

<br />

# Example Usage
The workflow file contains a good [example](https://github.com/jake-young-dev/go-install-script/blob/master/.github/workflows/test.yaml#L17), I recommend using a tagged release to avoid unexpected changes that may come to the master branch.

<br />

# Issues
This repo is a as brain-dead as I could make. The code is loosely based off of the go tool script from [catthehacker](https://github.com/catthehacker/docker_images/blob/master/linux/ubuntu/scripts/go.sh). Please open an issue for any problems or suggestions.

# Testing
A simple testing job is triggered on a push to the master branch, the job will create a mock go.mod file to ensure that one is present in testing container
