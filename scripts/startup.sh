#!/usr/bin/env bash

# bash strict mode
set -euo pipefail

# Reading ENV
set +u
repo_owner=$REPO_OWNER
repo_name=$REPO_NAME
gh_access_token=$GH_ACCESS_TOKEN
runner_name=$RUNNER_NAME
runner_group=$RUNNER_GROUP
runner_labels=$RUNNER_LABELS
runner_work=$RUNNER_WORK
runner_replace=$RUNNER_REPLACE
user_pass=$USER_PASS
set -u

# check required env
echo -n 'Checking required environment variables... '
if [ -n "$repo_owner" ] && [ -n "$repo_name" ] && [ -n "$gh_access_token" ]; then
  echo 'Done.'
else
  echo 'Failed!'
  echo ' '
  echo 'Something went wrong. Please check your environment variables and try again.'
  exit 1
fi

# check runner pass to overwrite init password
if [ -n "$user_pass" ]; then
  echo -e "Start123!.\n$user_pass\n$user_pass" | passwd -q runner
fi

# request token via api
echo -n 'Requesting token... '
api_url_register="https://api.github.com/repos/$repo_owner/$repo_name/actions/runners/registration-token"
register_response=$(curl -s -L -X POST -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $gh_access_token" -H "X-GitHub-Api-Version: 2022-11-28" $api_url_register)
token=$(echo "$register_response" | jq -r '.token')
echo 'Done.'

# get config parameters
config_params="--unattended --url https://github.com/$repo_owner/$repo_name --token $token"
echo '[DEBUG] Config parameters (without optional parameters): '$config_params

# add optional runner parameters
echo -n 'Checking optional parameters... '
if [ -n "$runner_name" ]; then
  config_params="$config_params --name $runner_name"
fi

if [ -n "$runner_group" ]; then
  config_params="$config_params --runnergroup $runner_group"
fi

if [ -n "$runner_labels" ]; then
  config_params="$config_params --labels $runner_labels"
fi

if [ -n "$runner_work" ]; then
  config_params="$config_params --work $runner_work"
fi

if [ $runner_replace == "true" ]; then
  config_params="$config_params --replace"
fi
echo 'Done.'

echo '[DEBUG] Config Paramerters (with optional parameters): '$config_params 

# Install actions runner on first run
if [ -f /opt/.docker_config/.first_run ]; then
  echo -n 'This is the first run of this container. Installing actions-runner... '
  mkdir actions-runner 
  cd ./actions-runner
  curl -s -o actions-runner-linux-arm64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-arm64-2.311.0.tar.gz
  tar xzf ./actions-runner-linux-arm64-2.311.0.tar.gz
  rm /opt/.docker_config/.first_run
  echo 'Done.'
  echo ' '
fi

# configure runner
./config.sh $config_params

# function for graceful shutdown by SIGTERM signal
shut_down() {
  echo ' '
  echo 'Recived termination signal (SIGTERM).'
  echo 'Unregister runner... '

  api_url_unregister="https://api.github.com/repos/$repo_owner/$repo_name/actions/runners/remove-token"
  unregister_response=$(curl -s -L -X POST -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $gh_access_token" -H "X-GitHub-Api-Version: 2022-11-28" $api_url_unregister)
  token=$(echo "$unregister_response" | jq -r '.token')
  ./config.sh remove --token $token

  echo -e '\nDone. Have a nice day!'
  exit
}

# Trap to get signal for graceful shutdown
trap 'shut_down' SIGTERM

# start runner
./run.sh & wait
