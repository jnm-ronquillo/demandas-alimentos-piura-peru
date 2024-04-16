# demandas-violencia-piura-peru
DE Zoomcamp project about cases of violence against women using data from datosabiertos.gob.pe of Corte Superior de Justicia de Piura

# Deploy Mage to Digitalocean
Download Mage terraform scripts. 

```bash
git clone https://github.com/mage-ai/mage-ai-terraform-templates.git
```

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
