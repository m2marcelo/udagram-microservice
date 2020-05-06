# udagram-microservice
Third project for Udacity Cloud Developer nanodegree.

## Getting started

The following sections will explain the step by step for the project.

### Software and services needed

You need to have accounts in AWS and Docker to execute this project, check details:
- Login or create an [Amazon Web Services](https://console.aws.amazon.com) account.
- Login or create a [DockerHub](https://hub.docker.com/) account.

Then you will need to have the followint softwares installed in your local machine:
- [AWS CLI](https://aws.amazon.com/cli/)
- [Docker](https://www.docker.com/products/docker-desktop)
- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [KubeOne](https://github.com/kubermatic/kubeone)

### Get the code for Udagram

Clone this repository on your, like this:

```
git@github.com:m2marcelo/udagram-microservice.git
```

## Getting started
AWS configurations

### Create an IAM user and group

Go to IAM on AWS and create a a group and an user, then add some permissions, that you will need, like AmazonEC2FullAccess, AmazonConnectFullAccess,IAMUserChangePassword.

### Create a PostgreSQL Instance

The application is using `PostgreSQL` database to store the feed data.

Create a PostgresSQL instance via Amazon RDS.

Add the ```udagram_common``` VPC security group to your Database instance so the services can access it.

### Create an S3 bucket

Udagram needs to use an S3 bucket for storing images, so you will need an AWS S3 Bucket created and configured, give a name for it, you will need for further configurations, the configurations in S3 are these: 

#### On Permissions -> bucket policy

Save the following policy in the Bucket policy editor:

```JSON
{
 "Version": "2012-10-17",
 "Id": "Policy1565786082197",
 "Statement": [
 {
 "Sid": "Stmt1565786073670",
 "Effect": "Allow",
 "Principal": {
 "AWS": "__YOUR_USER_ARN__"
 },
 "Action": [
 "s3:GetObject",
 "s3:PutObject"
 ],
 "Resource": "__YOUR_BUCKET_ARN__/*"
 }
 ]
}
```
#### IMPORTANT
The variables `__YOUR_USER_ARN__` and `__YOUR_BUCKET_ARN__` NEEDS to be replaced with your own ARN data, you can check this data on IAM -> User.

#### On Permissions -> CORS configuration

Save this configuration in the CORS configuration Editor:

```XML
<?xml version="1.0" encoding="UTF-8"?>
 <CORSConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
 <CORSRule>
 <AllowedOrigin>*</AllowedOrigin>
 <AllowedMethod>GET</AllowedMethod>
 <AllowedMethod>POST</AllowedMethod>
 <AllowedMethod>DELETE</AllowedMethod>
 <AllowedMethod>PUT</AllowedMethod>
 <MaxAgeSeconds>3000</MaxAgeSeconds>
 <AllowedHeader>Authorization</AllowedHeader>
 <AllowedHeader>Content-Type</AllowedHeader>
 </CORSRule>
</CORSConfiguration>
```

## Deploy on local using Docker

`Docker` will be used to start the application on your local machine.

During the course you will probably be familiar with these variables and what they are, so you need to add in your local machin as environment variables:

```
POSTGRES_USERNAME=__YOUR_USERNAME__
POSTGRES_PASSWORD=__YOUR_PASSWORD__
POSTGRES_DATABASE=__YOUR_DATABASE__
POSTGRESS_HOST=__YOUR_HOST__
JWT_SECRET=__YOUR_SECRETE__
AWS_MEDIA_BUCKET=__YOUR_AWS_BUCKET_NAME__
AWS_REGION=__YOUR_AWS_BUCKET_REGION__
AWS_PROFILE=__YOUR_AWS_PROFILE__
```

#### IMPORTANT
Replace the variables `__YOUR_*` with your information.

### Build and deploy in docker

Build the images by running these commands on build/docker folder:

```
docker-compose -f docker-compose-build.yaml build --parallel
```

Start the application and services:

```
docker-compose up
```

The application is now running at http://localhost:8100

## Deploy on AWS

The application needs to run in AWS using kubernetes.

### Create a Kubernetes cluster

#### Provision the infrastructure

First of all, add the following variables to your local environment:

```
AWS_ACCESS_KEY_ID=__YOUR_AWS_ACCES_KEY_ID__
AWS_SECRET_ACCESS_KEY=__YOUR_AWS_SECRET_ACCESS_KEY__
```
Then you will need to install kubeone and use terraform scripts to configure your environment.

Find info in [here](https://github.com/kubermatic/kubeone/blob/master/docs/quickstart-aws.md).

Important for yout environment is to have your variables to be used in terraform.

For the terraform.tfvars add info like this:

```
cluster_name = "udagram"
aws_region = "__YOUR_AWS_REGION__"
worker_os = "ubuntu"
ssh_public_key_file = "~/.ssh/id_rsa.pub"
```

Remember to add your own information in here as well.

#### Install Kubernetes

After run the terraform script, rembember to follow the guide, that teaches you how and why to create the config.yaml and tf.json file, you will need to execute the following command:

```
kubeone install config.yaml --tfjson tf.json
```

After Kubernetes was installed, export the following variable to your environment:

```
KUBECONFIG=$PWD/udagram-kubeconfig
```

#### Delete the cluster

If you need to delete the cluster you can run these commands:

```
kubeone reset config.yaml --tfjson tf.json
```

```
terraform destroy
```

## Running tge Kubernetes

### Deploy the application services

Deploy and start the application and services on Kubernetes by executing:

```
./build/k8s/deploy_services.sh
```

### Deploy the Kubernetes pods


Deploy the Kubernetes pods by running

```
./build/k8s/deploy.sh
```

That's it! :)