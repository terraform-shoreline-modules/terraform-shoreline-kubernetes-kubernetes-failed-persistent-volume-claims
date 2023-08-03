
#!/bin/bash

STORAGE_PROVISIONER_NAMESPACE="PLACEHOLDER"

STORAGE_PROVISIONER_YAML_FILE="PLACEHOLDER"

STORAGE_PROVISIONER_POD_NAME="PLACEHOLDER"

STORAGE_PROVISIONER_YAML_FILE="PLACEHOLDER"



# Check if the storage provisioner is installed

if ! kubectl get storageclass ${STORAGE_CLASS_NAME} &> /dev/null; then

  echo "Storage provisioner ${STORAGE_CLASS_NAME} not found. Installing..."

  kubectl apply -f ${STORAGE_PROVISIONER_YAML_FILE}

fi



# Check if the storage provisioner is running

if ! kubectl get pods -n ${STORAGE_PROVISIONER_NAMESPACE} | grep ${STORAGE_PROVISIONER_POD_NAME} | grep Running &> /dev/null; then

  echo "Storage provisioner ${STORAGE_PROVISIONER_POD_NAME} not running. Restarting..."

  kubectl delete pod ${STORAGE_PROVISIONER_POD_NAME} -n ${STORAGE_PROVISIONER_NAMESPACE}

fi



echo "Storage provisioner ${STORAGE_CLASS_NAME} is correctly configured and running."