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

Each environment is separated in a logical network using AWS VPC with non-overlapping CIDR block.

An ECS cluster is created using Autoscaling group as capacity provider. For saving money, Spot instances have been used. ECS services are launched in the ECS cluster on top of EC2 instances managed by an Autoscaling group.

An RDS Mysql database is created in a separated database subnet group.

The entire application resources, except for the logical network, are self-contained in a Terraform module configurable.

At the apply phase, Terraform generates as output an ECS Task Definition JSON file one for each environment where the Invo application is deployed and it stores them in the repository.

The Task definition is used as Artifact in Spinnaker to deploy the ECS Service on the ECS cluster.

## Continuous Integration

The Invo application is built using Jenkins as the specified requirement. 

Jenkins has been installed in a local cluster using an Helm Chart applied trough ArgoCD. The configuration is available [here](../homelab/jenkins.yaml).

A `Jenkinsfile` is provided to run the build with Kaniko on a Kubernetes cluster hosted in an home lab following a Declarative Pipeline approach. Kaniko is used due to the fact that Jenkins runs on top of a Kubernetes cluster which nowadays do not come anymore with Docker pre-built.

![jenkins](/images/jenkins.png "Jenkins").

In Jenkins we have a Job named `BuildInvoWithKaniko` started by Spinnaker which after some preparation build the Invo image and push it to the Docker Hub registry.

We could have added another job that would handle the ECS deployment. However ECS does not provide by default all the primitives to make a blue-green rollout. Recently AWS released a service named after this rollout strategy that it makes the rollout seamless. However Spinnaker represents an undisputed method to deploy seamless, fast and highly controllable ECS services.

## Continuous Deployment

[Spinnaker](https://spinnaker.io) is used to deploy the Docker Image of Invo built with Jenkins. A Spinnaker installation is hosted in the home lab where the Jenkins is located.

![spinnaker](/images/spinnaker.png "Spinnaker").

Thanks to Spinnaker, the blue-green deployment comes out of the box and it is possible to achieve a series of deployment mechanisms that within Jenkins would be much harder to accomplish. Spinnaker provides the Highlander strategy known also as blue-green deployment that create a new ECS Service and switch traffic over.

The pipeline to deploy new releases has been provided along the repository and available [here](../pipeline.json).

## Access

The access requirement is fullfilled using AWS IAM. The access to the `staging` environment is controlled assigning an IAM policy to the specific group to which the user is then added. The policy allows actions to only those resources having the tag `Environment=stg`.

Please note that this approach despite it works pretty well, it is hard to mantain. In a real world scenario, the best approach would be to separate accounts as primarily recommended by AWS.

## Observability

The application writes logs in a CloudWatch group that it is automatically created using the `awslogs` driver and thanks to the ECS Container Insights feature, it is possible to monitor constantly the performance of the container application.

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

## Release

In order to create a new release and deploy a new version of the application it is enough to create a new git tag on the VCS.

A Webhook is registered on Spinnaker and it will automatically start a new pipeline, building a new Docker Image with the tag as the Git tag and deploy automatically to the ECS Cluster.

## Improvements

- In a real scenario, Terraform would use the S3 remote storage backend. In such exercise we have used the local backend.
- A DNS name would be required in a real scenario and assigned to the Application Load Balancer.
- If the application would be available worldwide with customers spread around the world, a CDN would be required to cache contents effectively and improve the user experience.
- In a real scenario, production would differs from staging in terms of compute instance types of the Autoscaling Group and the Mysql database. For such exercise, instance types are the same to save costs inside the AWS Cloud account used to test resources.
- In a real scenario, CloudWatch alerts must be created to monitor at least primary SLIs such as CPU and Memory and Health Check. In addition it should be required to instrument accordingly the application to get application metrics like requests counts, errors, etc.
- In a real scenario, there should be implemented in CI tests to validate that the application can be shipped without issues. 
- In a real scenario, the two environments would be placed into two different AWS accounts. 
