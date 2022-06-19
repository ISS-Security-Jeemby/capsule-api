# timecapsule-api
API to store and retrieve capsule text

## Routes
All routes return Json
* GET `/`: Root route shows if Web API is running

### `api/v1/accounts`
* GET `api/v1/accounts/[username]`: Get account details
* POST `api/v1/accounts`: Create a new acounts

### `api/v1/auth`
* POST `api/v1/auth/register`: return an verification email if register success
* POST `/api/v1/auth/authenticate`: return an result if register success
* POST `/api/v1/auth/sso`: Get Github account information from Github url and create one in our db
* POST `/api/v1/auth/google_sso`:Get Google account information from Google url and create one in our db

### `api/v1/capsules`
* GET `api/v1/capsules/[caps_id]/letters/received`: Get received letters
* GET `api/v1/capsules/[caps_id]/letters/shared`: Get shared letters
* GET `api/v1/capsules/[caps_id]/letters`: Get list of letters for capsule
* GET `api/v1/capsules/[caps_id]`: Get information about a capsule
* GET `api/v1/capsules`: Get list of all capsules
* POST `api/v1/capsules/[caps_id]/letters`: Create letter for a capsule
* POST `api/v1/capsules/[account_id]`: Create three capsules for account after registration

### `api/v1/letters`
* GET `api/v1/letters/[letter_id]`: Get information about a letter 
* GET `api/v1/letters/collaborators`: Get collaborator list of each letter in shared capsule
* GET `api/v1/letters/[letter_id]/collaborators`: Get collaborators of the letter
* GET `api/v1/letters/[letter_id]/received`: Get information about a received letter
* POST `api/v1/letters/[letter_id]/collaborators`: Add collaborator to a letter
* POST `api/v1/letters/notice`: 
* PUT `api/v1/letters/[letter_id]`: Update letter data
* DELETE `api/v1/letters/[letter_id]`: Delete a certain letter by its id


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

```shell
rackup
```

## Release check
Before submitting pull requests, please check if specs, style, and dependency audits pass (will need to be online to update dependency database):
```
rake release?
```
