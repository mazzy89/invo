# Invo Terraform

Terraform directory which contains all the required resources to host on AWS the Invo application.

## Features

- Virtual Private Cloud
- ECS cluster
- Application Load Balancer
- Autoscaling group with Spot Instances mixed policy
- RDS Mysql Database
- IAM Access policy based on environment

## Structure

```sh
.
├── README.md
├── global
│   └── iam
├── modules
│   └── invo
├── prod
│   ├── invo.tf
│   ├── locals.tf
│   ├── main.tf
│   ├── terraform.tfstate
│   ├── terraform.tfstate.backup
│   ├── variables.tf
│   └── vpc.tf
└── stg
    ├── invo.tf
    ├── locals.tf
    ├── main.tf
    ├── terraform.tfstate
    ├── terraform.tfstate.backup
    ├── variables.tf
    └── vpc.tf
```

## Walkthrough

Terraform generates as output an ECS Task Definition JSON file one for each environment where the Invo application is deployed.

The Task definition is used as Artifact in Spinnaker to deploy the ECS Service on the ECS cluster.

## Continuous Integration

The Invo application is built using Jenkins as the requirement. A `Jenkinsfile` is provided to run the build with Kaniko on a Kubernetes cluster hosted in an home lab. Kaniko is used because Jenkins runs on top of a Kubernetes cluster which nowadays do not come anymore with Docker pre-built.

## Continuous Deployment

[Spinnaker](https://spinnaker.io) is used to deploy the Docker Image of Invo built with Jenkins. A Spinnaker installation is hosted in the home lab where the Jenkins is located.

Thanks to Spinnaker, the blue-green deployment comes out of the box and it is possible to achieve a series of deployment mechanisms that within Jenkins would be much harder to accomplish.

## Access

The access requirement is fullfilled using AWS IAM. The access to the `staging` environment is controlled assigning an IAM policy to the specific group to which the user is then added. The policy allows actions to only those resources having the tag `Environment=stg`.

Please note that this approach despite it works pretty well, it is hard to mantain. In a real world scenario, the best approach would be to separate accounts as primarily recommended by AWS.

## Observability

The application writes logs in a CloudWatch groups and thanks to the ECS Container Insights feature, it is possible to monitor constantly the performance of the application.

## Run

Install [`tfenv`](https://github.com/tfutils/tfenv) and run `tfenv install` in the environment directory under `terraform`.

Make sure to configure locally the AWS CLI with the IAM user or IAM role with the required privileges to spin up a full environement. It is required to have `AdministratorAccess` job function. `PowerUserAccess` is not enough because Terraform handles IAM.

### Staging

```sh
cd terraform/stg
terraform init
terraform plan
terraform apply
```

### Production

```sh
cd terraform/prod
terraform init
terraform plan
terraform apply
```

## Improvements

- In a real scenario, the Terraform would use the S3 remote storage backend.
- A DNS name would be required in a real scenario and assigned to the Application Load Balancer.
- If the application would be available worldwide with customers spread around the world, a CDN would be required to cache contents effectively and improve the user experience.
- In a real scenario, production would differs from staging in terms of compute instance types. For such exercise, instance types are the same to save costs inside the AWS Cloud account used to test resources.
