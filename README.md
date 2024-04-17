# demandas-alimentos-piura-peru
DE Zoomcamp project about food demands using data from datosabiertos.gob.pe of Corte Superior de Justicia de Piura

# Deploy Mage to Digitalocean

Generate DigitalOcean access token by following the guide: https://developer.hashicorp.com/terraform/tutorials/applications/digitalocean-provider#generate-digitalocean-access-token

```bash
export DIGITALOCEAN_ACCESS_TOKEN=
```

## Create ssh key with command:
```bash
ssh-keygen -t rsa -C "youremail@domain.com" -f ~/.ssh/tf-digitalocean
```
In the file ./digitalocean/variables.tf, update the value of ssh_pub_key to your path of public key.

```code
variable "ssh_pub_key" {
  description = "Path to SSH public key"
  default     = "~/.ssh/tf-digitalocean.pub"
}
```

## Provision resources
```bash
cd digitalocean
terraform plan
terraform init
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

Create a Service Account 

IAM & Admin -> Service Accounts

Roles:

Cloud Storage -> Storage Admin
BigQuery -> BigQuery Admin

Next to the service account created in the actions column
Select "Manage keys"
ADD KEY -> Create new key
Select "JSON"

On Mage in the pipeline -> alimentos ->Edit pipeline
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
