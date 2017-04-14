It is assumed (but not [required](/setup/requirements/storage)) that you would prefer to use Google Cloud Storage (GCS) as your persistence storage mechanism.

In order to use Google Cloud Storage, you must create a new service account and download its key. This service account should have permissions _for the project Spinnaker will run in_.

It is only necessary to create one storage credential for a Spinnaker instance.

Create the service account with the necessary permissions:

```bash
PROJECT=$(gcloud info --format='value(config.project)') # project that Spinnaker will run in.
SA_NAME=spinnaker-storage

gcloud iam service-accounts create \
    $SA_NAME \
    --display-name $SA_NAME

SA_EMAIL=$(gcloud iam service-accounts list \
    --filter="displayName:$SA_NAME" \
    --format='value(email)')

gcloud projects add-iam-policy-binding $PROJECT \
    --role roles/storage.admin --member serviceAccount:$SA_EMAIL
```