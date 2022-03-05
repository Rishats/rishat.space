#!/bin/bash

# Variables
SERVICE_ACCOUNT_NAME="rishat-space-production-service-account"
CONTEXT=$(kubectl config current-context)
NAMESPACE=rishat-space-production
NEW_CONTEXT=rishat-space-production
KUBECONFIG_FILE="kubeconfig-rishat-space-production"


# Get Service account Bearer token if need
KSERVICE=$(kubectl get serviceaccount $SERVICE_ACCOUNT_NAME -o=jsonpath='{.secrets[0].name}' -n rishat-space-production)
KSECRET=$(kubectl get secrets  $KSERVICE  -o=jsonpath='{.data.token}' -n rishat-space-production | base64 --decode )
echo "----------------------------------------------"
echo ""
echo $KSECRET
echo ""
echo "----------------------------------------------"

# Generate kubeconfig
SECRET_NAME=$(kubectl get serviceaccount ${SERVICE_ACCOUNT_NAME} \
  --context ${CONTEXT} \
  --namespace ${NAMESPACE} \
  -o jsonpath='{.secrets[0].name}')
TOKEN_DATA=$(kubectl get secret ${SECRET_NAME} \
  --context ${CONTEXT} \
  --namespace ${NAMESPACE} \
  -o jsonpath='{.data.token}')

TOKEN=$(echo ${TOKEN_DATA} | base64 -d)

# Create dedicated kubeconfig
# Create a full copy
kubectl config view --raw > ${KUBECONFIG_FILE}.full.tmp
# Switch working context to correct context
kubectl --kubeconfig ${KUBECONFIG_FILE}.full.tmp config use-context ${CONTEXT}
# Minify
kubectl --kubeconfig ${KUBECONFIG_FILE}.full.tmp \
  config view --flatten --minify > ${KUBECONFIG_FILE}.tmp
# Rename context
kubectl config --kubeconfig ${KUBECONFIG_FILE}.tmp \
  rename-context ${CONTEXT} ${NEW_CONTEXT}
# Create token user
kubectl config --kubeconfig ${KUBECONFIG_FILE}.tmp \
  set-credentials ${CONTEXT}-${NAMESPACE}-token-user \
  --token ${TOKEN}
# Set context to use token user
kubectl config --kubeconfig ${KUBECONFIG_FILE}.tmp \
  set-context ${NEW_CONTEXT} --user ${CONTEXT}-${NAMESPACE}-token-user
# Set context to correct namespace
kubectl config --kubeconfig ${KUBECONFIG_FILE}.tmp \
  set-context ${NEW_CONTEXT} --namespace ${NAMESPACE}
# Flatten/minify kubeconfig
kubectl config --kubeconfig ${KUBECONFIG_FILE}.tmp \
  view --flatten --minify > ${KUBECONFIG_FILE}
# Remove tmp
rm ${KUBECONFIG_FILE}.full.tmp
rm ${KUBECONFIG_FILE}.tmp

echo "----------------------------------------------"
echo ""
base64 $KUBECONFIG_FILE
echo ""
echo "----------------------------------------------"


