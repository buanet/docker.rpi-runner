#!/usr/bin/env bash

# bash strict mode
set -euo pipefail

# check env
echo -n 'Checking environment variables... '
if [[ -z "${REPO_OWNER}" ]] || [[ -z "${REPO_NAME}" ]] || [[ -z "${GH_ACCESS_TOKEN}" ]]; then
  echo 'Failed!'
  echo ' '
  echo 'Something went wrong. Please check your environment variables and try again.'
  exit 1
else
  echo 'Done.'
fi

# request token via api
api_url_register='https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/actions/runners/registration-token'
register_response=$(curl -s -L -X POST -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $GH_ACCESS_TOKEN" -H "X-GitHub-Api-Version: 2022-11-28" $api_url_register)
token=$(echo "$register_response" | jq -r '.token')

# get config parameters
config_params='--url https://github.com/$REPO_OWNER/$REPO_NAME --token $token'

if [[ -f /opt/.docker_config/.first_run ]]; then
  # Install actions runner
    mkdir actions-runner 
    cd ./actions-runner
    curl -o actions-runner-linux-arm64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-arm64-2.311.0.tar.gz
    tar xzf ./actions-runner-linux-arm64-2.311.0.tar.gz
    ./config.sh $config_params
fi

# Function for graceful shutdown by SIGTERM signal
shut_down() {
  echo ' '
  echo 'Recived termination signal (SIGTERM).'
  echo 'Unregister runner... '

  api_url_unregister='https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/actions/runners/remove-token'
  unregister_response=$(curl -s -L -X POST -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $GH_ACCESS_TOKEN" -H "X-GitHub-Api-Version: 2022-11-28" $api_url_unregister)
  token=$(echo "$unregister_response" | jq -r '.token')
  ./config.sh remove --url https://github.com/$REPO_OWNER/$REPO_NAME --token $token

  echo -e '\nDone. Have a nice day!'
  exit
}

# Trap to get signal for graceful shutdown
trap 'shut_down' SIGTERM

# start runner
./run.sh & wait
