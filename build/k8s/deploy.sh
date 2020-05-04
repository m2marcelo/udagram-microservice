#!/bin/bash

#  set -e

 echo $PWD
 echo $(ls)

 DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
 
 echo "Passo 0 - criando certificados"
 
#  echo ${KUBE_CERTIFICATE} | base64 --decode > udagram-ca.pem
#  echo ${KUBE_ADMIN_CERTIFICATE} | base64 --decode > udagram-client-ca.pem
#  echo ${KUBE_ADMIN_KEY_DATA} | base64 --decode > udagram-key.pem

#  echo "Passo 0 - ajustando configs"

#  echo "Passo 0 - config 1"
#  kubectl config set-cluster marcelo-cluster-udagram --server=${KUBE_SERVER_URL} --certificate-authority=udagram-ca.pem
#  echo "Passo 0 - config 2"
#  kubectl config set-credentials kubernetes-admin --client-certificate=udagram-client-ca.pem --client-key=udagram-key.pem
#  echo "Passo 0 - config 3"
#  kubectl config set-context kubernetes-admin@marcelo-cluster-udagram --cluster=marcelo-cluster-udagram --namespace=default --user=kubernetes-admin
#  echo "Passo 0 - config 4"
#  kubectl config use-context kubernetes-admin@marcelo-cluster-udagram

 echo "Passo 1 DIR = $DIR"

 configmap=`cat "$DIR/env-configmap.yaml" | sed "s/{{AWS_MEDIA_BUCKET}}/$AWS_MEDIA_BUCKET/g;s/{{AWS_PROFILE}}/$AWS_PROFILE/g;s/{{AWS_REGION}}/$AWS_REGION/g;s/{{POSTGRES_DATABASE}}/$POSTGRES_DATABASE/g;s/{{POSTGRES_HOST}}/$POSTGRES_HOST/g;s#{{APP_URL}}#$APP_URL#g"`
 echo "$configmap" | kubectl apply -f -

 echo "Passo 2"
 secret=`cat "$DIR/env-secret.yaml" | sed "s/{{JWT_SECRET}}/$JWT_SECRET/g;s/{{POSTGRES_USERNAME}}/$POSTGRES_USERNAME/g;s/{{POSTGRES_PASSWORD}}/$POSTGRES_PASSWORD/g;s/{{KUBECONFIG_AWS}}/$KUBECONFIG_AWS/g"`
 echo "$secret" | kubectl apply -f -

 echo "Passo 3"

 awsCredentials=`cat $DIR/.aws/credentials | base64`
 awsSecret=`cat "$DIR/aws-secret.yaml" | sed "s/{{AWS_CREDENTIALS}}/$awsCredentials/g"`
 echo "$awsSecret" | kubectl apply -f -

echo "Passo 4"

kubectl apply -f $DIR/backend-feed-deployment.yaml
kubectl apply -f $DIR/backend-user-deployment.yaml
kubectl apply -f $DIR/reverseproxy-deployment.yaml
kubectl apply -f $DIR/frontend-deployment.yaml
