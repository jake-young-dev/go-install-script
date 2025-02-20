# go-install-script
A simple, hacky script to installa single Golang version on git action runner workflows for faster pipelines. When using [actions/setup-go](https://github.com/actions/setup-go) my testing pipelines averaged 8-10 minutes, however, with this script they are down to ~20s.

# Issues
This repo is a as brain-dead as I could make it and will only work for linux releases for now. The bash code is loosely based off of the go tool script from [catthehacker](https://github.com/catthehacker/docker_images/blob/master/linux/ubuntu/scripts/go.sh). I am not very experienced in bash so if you have any improvements, recommendations, or bug fixes please open an issue or a PR.

# Testing
A simple testing job is triggered on a push to any branch, the job will create a mock go.mod file to ensure that one is present in testing container
