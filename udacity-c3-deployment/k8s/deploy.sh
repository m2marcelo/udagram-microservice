#!/bin/bash

#  set -e

 echo $PWD
 echo $(ls)

 echo "Passo 1"
 configmap=`cat "./udacity-c3-deployment/k8s/env-configmap.yaml" | sed "s/{{AWS_MEDIA_BUCKET}}/$AWS_MEDIA_BUCKET/g;s/{{AWS_PROFILE}}/$AWS_PROFILE/g;s/{{AWS_REGION}}/$AWS_REGION/g;s/{{POSTGRES_DATABASE}}/$POSTGRES_DATABASE/g;s/{{POSTGRES_HOST}}/$POSTGRES_HOST/g;s#{{APP_URL}}#$APP_URL#g"`
 echo "configmap = $configmap"
 echo "$configmap" | kubectl apply -f -

 echo "Passo 2"
 secret=`cat "./udacity-c3-deployment/k8s/env-secret.yaml" | sed "s/{{JWT_SECRET}}/$JWT_SECRET/g;s/{{POSTGRES_USERNAME}}/$POSTGRES_USERNAME/g;s/{{POSTGRES_PASSWORD}}/$POSTGRES_PASSWORD/g;s/{{KUBECONFIG_AWS}}/$KUBECONFIG_AWS/g"`
 echo "secret = $secret"
 echo "$secret" | kubectl apply -f -

 echo "Passo 3"

 awsCredentials=`cat ~/.aws/credentials | base64`
 awsSecret=`cat "./udacity-c3-deployment/k8s/aws-secret.yaml" | sed "s/{{AWS_CREDENTIALS}}/$awsCredentials/g"`
 echo "awsSecret = $awsSecret"
 echo "$awsSecret" | kubectl apply -f -

echo "Passo 4"

kubectl apply -f ./backend-feed-deployment.yaml
kubectl apply -f ./backend-user-deployment.yaml
kubectl apply -f ./reverseproxy-deployment.yaml
kubectl apply -f ./frontend-deployment.yaml 