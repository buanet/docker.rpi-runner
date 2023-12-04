Run a self hosted GitHub actions runner in Docker on a Raspberry Pi 3/4/5 (64-bit).

## Environment variables

|ENV|Description|
|---|---|
|REPO_OWNER|Owner of the Repo for runner registration|
|REPO_NAME|Name of the Repo for runner registration|
|GH_ACCESS_TOKEN|GitHub personal access token (scope "repo") for register/ unregister runner|
|RUNNER_NAME|(optional) Name of the runner|
|RUNNER_GROUP|Name of the runner group to add this runner to|
|RUNNER_LABELS|Extra labels in addition to the default|
|RUNNER_WORK|Relative runner work directory|
|RUNNER_REPLACE||Replace any existing runner with the same name|

