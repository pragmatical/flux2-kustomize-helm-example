#!/bin/sh

# installing k3d
wget -q -O - https://raw.githubusercontent.com/rancher/k3d/main/install.sh | TAG=v5.4.4 bash

#installing clusterctl
curl -L https://github.com/kubernetes-sigs/cluster-api/releases/download/v1.1.5/clusterctl-linux-amd64 -o clusterctl
chmod +x ./clusterctl
sudo mv ./clusterctl /usr/local/bin/clusterctl

# creating local registry
docker network create k3d
k3d registry create registry.localhost --port 5000
docker network connect k3d k3d-registry.localhost

# creating k3d cluster
k3d cluster delete ngsa-asb
k3d cluster create ngsa-asb --registry-use k3d-registry.localhost:5000 --config .devcontainer/k3d.yaml --k3s-arg "--disable=traefik@server:0" --k3s-arg "--disable=servicelb@server:0"

# installing flux binary
sudo rm -f /usr/local/bin/flux
curl --location --silent --output /tmp/flux.tar.gz "https://github.com/fluxcd/flux2/releases/download/v0.32.0/flux_0.32.0_linux_amd64.tar.gz"
sudo tar --extract --gzip --directory /usr/local/bin --file /tmp/flux.tar.gz
rm /tmp/flux.tar.gz

# installing flux
flux install >> "$HOME/status"