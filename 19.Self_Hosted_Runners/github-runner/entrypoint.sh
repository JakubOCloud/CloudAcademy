#!/bin/bash

set -e

cd /home/runner

./config.sh \
    --url "${GITHUB_REPOSITORY_URL}" \
    --token "${RUNNER_TOKEN}" \
    --name "${RUNNER_NAME}" \
    --labels "self-hosted,kubernetes,minikube" \
    --unattended \
    --replace

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --unattended --token "${RUNNER_TOKEN}" || true
}

trap cleanup EXIT

./run.sh