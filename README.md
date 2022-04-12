# timecapsule-api
API to store and retrieve capsule text

## Routes
All routes return Json
* GET `/`: Root route shows if Web API is running
* GET `api/v1/accounts/[username]`: Get account details
* POST `api/v1/accounts`: Create a new acounts
* GET `api/v1/capsules/[caps_id]/letters/[doc_id]`: Get a letter
* GET `api/v1/capsules/[caps_id]/letters`: Get list of letters for capsule
* POST `api/v1/capsules/[caps_id]/letters`: Upload letter for a capsule
* GET `api/v1/capsules/[caps_]`: Get information about a capsule
* GET `api/v1/capsules`: Get list of all capsules
* POST `api/v1/capsules`: Create new capsule

## Install
Install this API by cloning the relevant branch and installing required gems from `Gemfile.lock`:
```
bundle install
```
Setup development database once:
```
rake db:migrate
```

## Test
Setup test database once:
```
RACK_ENV=test rake db:migrate
```
Run the test specification script in `Rakefile`:
```
rake spec
```

## Develop/Debug
Add fake data to the development database to work on this project:
```
rake db:seed
```

## Execute
Launch the API using:
```
rake run:dev
```

## Release check
Before submitting pull requests, please check if specs, style, and dependency audits pass (will need to be online to update dependency database):
```
rake release?
```
