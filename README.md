# Deploy to Google Cloud Storage as Website

A step that deploys website to Google Cloud Storage.

It requires a `.boto` config file on the root of the repository,
and requires `gs_oauth2_refresh_token` and `default_project_id` lines in `.boto` like below:

    [Credentials]
    gs_access_key_id =
    gs_secret_access_key =
    [GSUtil]
    default_project_id =

see: https://cloud.google.com/storage/docs/gsutil/commands/config

It applies gzip content-encoding to file uploads with below extensions.

  * css
  * html
  * js
  * json
  * map
  * svg
  * txt
  * xml

## Options

### required

* `bucket` - A bucket name of the Google Cloud Storage.
* `project` - A project ID of the Google Cloud Platform.
* `access_key_id`, `secret_access_key` - The [HMAC Authentication and development key](https://cloud.google.com/storage/docs/migrating#keys) 

### options

* `dir` - A path to directory that is root of the website. The default value is `public`.

### initialize options

* `initialize` - A flag for initialize a bucket of the Google Cloud Storage via `gsutil mb` command. Not empty is True.
* `class` - A bucket storage class of the Google Cloud Storage.
* `location` - A bucket location of the Google Cloud Storage.

see: https://cloud.google.com/storage/docs/gsutil/commands/mb#bucket-locations

It will be created with the default (Standard) storage class.
It will be set the MainPageSuffix property to `index.html` and the NotFoundPage property to `404.html`.

## Example

```
deploy:
  steps:
  - narinari/gcs-website-deploy:
    bucket:   example.com
    project:  $GOOGLE_PROJECT_ID
    access_key_id:    $GCS_ACCESS_KEY_ID
    secret_access_key:    $GCS_SECRET_ACCESS_KEY

    # options
    dir:      public

    # if you want to initialize a bucket
    initialize: not_empty
    class:      DURABLE_REDUCED_AVAILABILITY
    location:   ASIA-EAST1
```
