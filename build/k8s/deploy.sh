#!/bin/bash

#  set -e

echo "Creating config map"
configmap=`cat "./env-configmap.yaml" | sed "s/{{AWS_MEDIA_BUCKET}}/$AWS_MEDIA_BUCKET/g;s/{{AWS_PROFILE}}/$AWS_PROFILE/g;s/{{AWS_REGION}}/$AWS_REGION/g;s/{{POSTGRES_DATABASE}}/$POSTGRES_DATABASE/g;s/{{POSTGRES_HOST}}/$POSTGRES_HOST/g;s#{{APP_URL}}#$APP_URL#g"`
echo "$configmap" | kubectl apply -f -
echo "Creating secret"
secret=`cat "./env-secret.yaml" | sed "s/{{JWT_SECRET}}/$JWT_SECRET/g;s/{{POSTGRES_USERNAME}}/$POSTGRES_USERNAME/g;s/{{POSTGRES_PASSWORD}}/$POSTGRES_PASSWORD/g;s/{{KUBECONFIG_AWS}}/$KUBECONFIG_AWS/g"`
echo "$secret" | kubectl apply -f -
echo "Creating aws secret"
awsSecret=`cat "./aws-secret.yaml"`
echo "$awsSecret" | kubectl apply -f -
echo "Creating pods"
kubectl apply -f ./backend-feed-deployment.yaml
kubectl apply -f ./backend-user-deployment.yaml
kubectl apply -f ./reverseproxy-deployment.yaml
kubectl apply -f ./frontend-deployment.yaml
