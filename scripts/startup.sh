#!/usr/bin/env bash

# bash strict mode
set -euo pipefail

if [[ -f /opt/.docker_config/.first_run ]]; then
  # Install actions runner
    mkdir actions-runner 
    cd ./actions-runner
    curl -o actions-runner-linux-arm64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-arm64-2.311.0.tar.gz
    tar xzf ./actions-runner-linux-arm64-2.311.0.tar.gz
    ./config.sh --url https://github.com/buanet/private.actionsrunner --token $TOKEN
fi

./run.sh
