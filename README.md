# timecapsule-api
API to store and retrieve capsule text

## Routes
All routes return Json
* GET `/`: Root route shows if Web API is running
* POST `api/v1/text/`: creates a new capsule text
* GET `api/v1/text/`: returns all confiugration IDs
* GET `api/v1/text/[id]`: returns details about a single capsule text with given ID

## Install
Install this API by cloning the relevant branch and installing required gems from `Gemfile.lock`:
```
bundle install
```
## Test
Run the test script:
```
ruby spec/api_spec.rb
```

## Execute
Run this API using:
```
rackup
```
