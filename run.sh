function install_gcs() {
debug 'Installing gsutil'
curl -sO https://storage.googleapis.com/pub/gsutil.tar.gz
rm -rf $WERCKER_CACHE_DIR/gsutil
tar xfz gsutil.tar.gz -C $WERCKER_CACHE_DIR
}

export PATH=${PATH}:$WERCKER_CACHE_DIR/gsutil
if ! type gsutil > /dev/null; then
  install_gcs
elif [ `gsutil version|awk '{print $3}'|tr -d "\\r\\n"` != \
     `curl -sI https://storage.googleapis.com/pub/gsutil.tar.gz|grep x-goog-meta-gsutil_version|awk '{print $2}'|tr -d "\\r\\n"` ]; then
  install_gcs
fi

debug 'setting gsutil'
echo "[Credentials]" > .boto
echo "gs_access_key_id = \"$WERCKER_GCS_WEBSITE_DEPLOY_ACCESS_KEY_ID\"" >> .boto
echo "gs_secret_access_key = \"$WERCKER_GCS_WEBSITE_DEPLOY_SECRET_ACCESS_KEY\"" >> .boto
echo "[GSUtil]" >> .boto
echo "default_project_id = $WERCKER_GCS_WEBSITE_DEPLOY_PROJECT" >> .boto

export BOTO_PATH=$PWD/.boto

# if WERCKER_GCS_WEBSITE_DEPLOY_INITIALIZE is not empty
if [ -n "$WERCKER_GCS_WEBSITE_DEPLOY_INITIALIZE" ]; then
debug 'Initial setting bucket'
gsutil mb -c $WERCKER_GCS_WEBSITE_DEPLOY_CLASS -l $WERCKER_GCS_WEBSITE_DEPLOY_LOCATION gs://$WERCKER_GCS_WEBSITE_DEPLOY_BUCKET
gsutil web set -m index.html -e 404.html gs://$WERCKER_GCS_WEBSITE_DEPLOY_BUCKET
gsutil defacl ch -u AllUsers:R gs://$WERCKER_GCS_WEBSITE_DEPLOY_BUCKET
fi

debug 'Starting deployment'

# if WERCKER_GCS_WEBSITE_DEPLOY_DIR is empty
[ -z "$WERCKER_GCS_WEBSITE_DEPLOY_DIR" ] &&
  WERCKER_GCS_WEBSITE_DEPLOY_DIR=public

gsutil -m rsync -r -d $WERCKER_GCS_WEBSITE_DEPLOY_DIR gs://$WERCKER_GCS_WEBSITE_DEPLOY_BUCKET
gsutil -m cp -r -z html,css,js,xml,txt,json,map,svg $WERCKER_GCS_WEBSITE_DEPLOY_DIR/* gs://$WERCKER_GCS_WEBSITE_DEPLOY_BUCKET

success 'Finished'
