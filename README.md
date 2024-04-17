# demandas-alimentos-piura-peru
DE Zoomcamp project about food demands using data from datosabiertos.gob.pe of Corte Superior de Justicia de Piura

# Deploy Mage to Digitalocean

Generate DigitalOcean access token by following the guide: https://developer.hashicorp.com/terraform/tutorials/applications/digitalocean-provider#generate-digitalocean-access-token
Save this access token for later.

```bash
export DIGITALOCEAN_ACCESS_TOKEN=
```

## Create ssh key with command:
```bash
ssh-keygen -t rsa -C "youremail@domain.com" -f ~/.ssh/tf-digitalocean
```
In the file mage-ai-terraform-templates/digitalocean/variables.tf, update the value of ssh_pub_key to your path of public key.

```code
variable "ssh_pub_key" {
  description = "Path to SSH public key"
  default     = "~/.ssh/tf-digitalocean.pub"
}
```

## Provision resources
```bash
cd mage-ai-terraform-templates/digitalocean
terraform init
terraform plan
terraform apply
```
Once it’s finished deploying, you can get the IP from the output.

## SSH into the instance
```bash
ssh -i ~/.ssh/tf-digitalocean root@[IP]
```
Run command to start Mage app in :
```bash
docker run -d -p 6789:6789 -v $(pwd):/home/src mageai/mageai /app/run_app.sh mage start default_repo
```
To access Mage using a browser enter the url: http://[IP]:6789

## Create a new Project in Google Cloud Console
Create a new project with any name for example 'deproject'

Create a Service Account 

IAM & Admin -> Service Accounts  
Create a new service account with any name for example 'alimentos' and the following Roles:

Cloud Storage -> Storage Admin  
BigQuery -> BigQuery Admin  
Leave empty: Grant users access to this service account 

Next to the service account created in the actions column  
Select "Manage keys"  
ADD KEY -> Create new key  
Select "JSON"  

## Import Mage pipeline
On Mage on Pipelines click + New -> Import pipeline zip  
Check: Override pipeline files  
Upload the file pipeline/demandas.zip

On Mage in the pipeline -> demandas ->Edit pipeline  
Right click in the default_repo -> New file  
Create a new file named key.json  
Copy the contents of the downloaded JSON file to key.json  
Delete the following properties from io_config.yaml file:  

```code
GOOGLE_SERVICE_ACC_KEY:
    type: service_account
    project_id: 
    private_key_id: 
    private_key: 
    client_email: 
    auth_uri: "https://accounts.google.com/o/oauth2/auth"
    token_uri: "https://oauth2.googleapis.com/token"
    auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs"
    client_x509_cert_url:
```

And add the path to the key file

```code
# Google
GOOGLE_SERVICE_ACC_KEY_FILEPATH: "/home/src/default_repo/key.json"
```

## Provision Google Cloud
In the file mage-ai-terraform-templates/googlecloud/variables.tf, update the value of the key json file.

```code
variable "credentials" {
  description = "My Credentials"
  default     = "~/.gc/deproject.json"
}
```

Update the name of the project
```code
variable "project" {
  description = "Project"
  default     = "deproject-420601"
}
```

Update the name of the bucket (recommended name: project_name + csjpiura)
```code
variable "gcs_bucket_name" {
  description = "My Storage Bucket Name"
  #Update the below to a unique bucket name
  default     = "deproject-420601-csjpiura"
}
```

## Provision resources on Google Cloud
```bash
cd mage-ai-terraform-templates/googlecloud
terraform init
terraform plan
terraform apply
```

## Update Mage pipeline

On Mage in the pipeline -> alimentos ->Edit pipeline  
In the data exporter step 'upload_date' change the project_id value to the name of the project. For example:
```code
project_id = 'deproject-420601'
```

Also change the bucket_name variable. For examlple:
```code
bucket_name = 'deproject-420601-csjpiura'
```

In the data exporter step 'external_table' change the the name of the project and bucket_name value. For example in the following the project name is deproject-420601 and the bucket name is deproject-420601-csjpiura:
```code
CREATE OR REPLACE EXTERNAL TABLE `deproject-420601.csjpiura.external_demandas_alimentos`
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://deproject-420601-csjpiura/demandas_alimentos/YEAR=2023/*.parquet']
);
```

## Init dbt project
I followed the step 1 and 2 from [Initialization of dbt via Docker](https://janzednicek.cz/en/etl-mage-ai-docker-installation-dbtsqlserver-dbt-debug-error-fix/)  

SSH into the instance
```bash
ssh -i ~/.ssh/tf-digitalocean root@[IP]
docker ps
```

Copy container_id from the previous output
```bash
docker exec -it [container_id] bash
```

```bash
cd default_repo
cd dbt
dbt init dbt_project
```
Answer the interactive questions:
```bash
Which database would you like to use?  
[7] bigquery
Enter a number: 7

[1] oauth
[2] service_account
Desired authentication method option (enter a number): 2

keyfile (/path/to/bigquery/keyfile.json): /home/src/default_repo/key.json

project (GCP project id): deproject-420601 (change it)

dataset (the name of your dbt dataset): csjpiura

threads (1 or more): 1

[1] US
[2] EU
Desired location option (enter a number): 1
```

Move profiles.yml to dbt_project/
```bash
mv profiles.yml dbt_project/
```

Test dbt connection
```bash
cd dbt_project/
dbt debug
```

Run the blocks in the pipeline one by one starting from the top to the bottom. 

## Add dbt Model manually
On Mage in default_repo expand folder dbt/dbt_project/models

Right click models folder -> Upload files

Upload the folder dbt_models/demandas/

After the last block click the button 'DBT model' -> Single model or snapshot(from file)

- Select category_model.sql  

Connect the dbt model after the block external_table in the Tree panel

Again after the last block click the button 'DBT model' -> Single model or snapshot(from file)

- Select temporal_model.sql  

Connect the last dbt model after the dbt model category_model in the Tree panel

To Run the dbt models click the ... circle button -> Run model


## Destroy resources
Finally drop the created resources. First manually delete the tables created in the dataset csjpiura on BigQuery. Next run terraform.

```bash
cd mage-ai-terraform-templates/googlecloud
terraform destroy
```

For digitalocean set the access token:

```bash
export DIGITALOCEAN_ACCESS_TOKEN=
```

```bash
cd ..
cd ..
cd mage-ai-terraform-templates/digitalocean
terraform destroy
```

Sometimes terraform fails to delete the ssh key on your digitalocean account. In this case delete the ssh key manually in the following section:

Settings -> Security -> SSH Keys
