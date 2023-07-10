#!/bin/bash -e

if [[ -z $GOOGLE_CLOUD_PROJECT ]]; then
    echo "GOOGLE_CLOUD_PROJECT not set. Run 'export GOOGLE_CLOUD_PROJECT=<project-id>' then try again"
    exit 1
fi

gcloud auth login --project $GOOGLE_CLOUD_PROJECT
echo
echo "Login successful, bootstrapping project."
echo
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
curl --silent \
https://storage.googleapis.com/storage/v1/projects/$GOOGLE_CLOUD_PROJECT/serviceAccount \
--header "Authorization: Bearer `gcloud auth print-access-token`"   \
--header 'Accept: application/json'   --compressed > /dev/null
project_num=$(gcloud projects describe $GOOGLE_CLOUD_PROJECT --format="value(projectNumber)")
project_id=$(gcloud projects describe $GOOGLE_CLOUD_PROJECT --format="value(projectId)")
curl -s -O https://raw.githubusercontent.com/astronomer/astro-gcp-onboarding/main/roles/astro-gcp-role.yaml
curl -s -O https://raw.githubusercontent.com/astronomer/astro-gcp-onboarding/main/roles/astro-gcp-role-api-service-agent.yaml
gcloud iam roles create astro_deployment_role_service_agent --project=$project_id --file=astro-gcp-role-api-service-agent.yaml
gcloud iam roles create astro_deployment_role --project=$project_id --file=astro-gcp-role.yaml
gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT --member=serviceAccount:$project_num@cloudservices.gserviceaccount.com --role=projects/$project_id/roles/astro_deployment_role_service_agent > /dev/null
gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT --member=serviceAccount:astronomer@astro-remote-mgmt.iam.gserviceaccount.com --role=projects/$project_id/roles/astro_deployment_role > /dev/null
echo
echo "Bootstrap successful."
