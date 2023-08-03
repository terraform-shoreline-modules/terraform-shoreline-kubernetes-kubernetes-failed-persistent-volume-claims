bash

#!/bin/bash



# Get the storage class

storage_class=$(kubectl get storageclass ${STORAGE_CLASS_NAME} -o jsonpath='{.provisioner}')



# Check if the storage class is available

if [ "$storage_class" != "${STORAGE_PROVIDER}" ]; then

  # If the storage class is not available, exit with an error

  echo "Error: Storage class ${STORAGE_CLASS_NAME} is not available."

  exit 1

else

  # If the storage class is available, exit with a success message

  echo "Storage class ${STORAGE_CLASS_NAME} is available and correctly configured."

  exit 0

fi