# Terraform Modules for AWS resources and more

Terraform modules for AWS to create the following resources: 
- VPC
- ALB
- NLB
- EC2
- REDIS
- SQS
- NGINX

### Prerequisites

Terraform client with aws plugin installed.

```
brew install terraform
```

### Executing

Pick the desired module and:

Change dir:

```
terraform-ec2-module 
```

Initialize terraform: 
```
terraform init 
```

Preview what the plan:
```
terraform plan -var 'var_name=value' 
```

Execute the plan:
```
terraform apply -var 'var_name=value' 
```


## Authors

* **Oz Giat** - [ozgiat](https://github.com/ozgiat)



