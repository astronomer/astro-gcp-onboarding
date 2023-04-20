#!/bin/bash -e

if [[ -z $GOOGLE_CLOUD_PROJECT ]]; then
    echo "GOOGLE_CLOUD_PROJECT not set. Run 'export GOOGLE_CLOUD_PROJECT=<project-id>' then try again"
    exit 1
fi

gcloud auth login
echo
echo "Login successful, bootstrapping project."
echo
gcloud services enable storage.googleapis.com
gcloud services enable storage-component.googleapis.com
gcloud services enable storage-api.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable container.googleapis.com
gcloud services enable deploymentmanager.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable cloudkms.googleapis.com
gcloud services enable sqladmin.googleapis.com
gcloud services enable servicenetworking.googleapis.com
gcloud services enable dns.googleapis.com
gcloud services enable servicedirectory.googleapis.com
curl --silent \
https://storage.googleapis.com/storage/v1/projects/$GOOGLE_CLOUD_PROJECT/serviceAccount \
--header "Authorization: Bearer `gcloud auth print-access-token`"   \
--header 'Accept: application/json'   --compressed > /dev/null
project_num=$(gcloud projects describe $GOOGLE_CLOUD_PROJECT --format="value(projectNumber)")
gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT --member=serviceAccount:$project_num@cloudservices.gserviceaccount.com --role=roles/owner > /dev/null
gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT --member=serviceAccount:astronomer@astro-remote-mgmt.iam.gserviceaccount.com --role=roles/owner > /dev/null
echo
echo "Bootstrap successful."
