
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Kubernetes - Failed Persistent Volume Claims
---

This incident type involves issues with persistent volume claims in a Kubernetes cluster. This could be due to storage problems or other configuration issues. It is important to resolve these issues promptly to ensure that the Kubernetes cluster is functioning properly.

### Parameters
```shell
# Environment Variables

export PVC_NAME="PLACEHOLDER"

export PV_NAME="PLACEHOLDER"

export SC_NAME="PLACEHOLDER"

export NAMESPACE="PLACEHOLDER"

export STORAGE_CLASS_NAME="PLACEHOLDER"

export STORAGE_PROVIDER="PLACEHOLDER"

```

## Debug

### Get a list of all PersistentVolumes
```shell
kubectl get pv
```

### Get a list of all PersistentVolumeClaims
```shell
kubectl get pvc
```

### Check the status of a specific PersistentVolumeClaim
```shell
kubectl describe pvc ${PVC_NAME}
```

### Check the status of a specific PersistentVolume
```shell
kubectl describe pv ${PV_NAME}
```
### Check the status of a specific storage class
```shell
kubectl describe sc ${SC_NAME}
```
###  Check for misconfiguration in the Persistent Volume Claims (PVCs) setting
```shell
#!/bin/bash

# Set the namespace and PVC name

namespace=${NAMESPACE}

pvc_name=${PVC_NAME}

# Get the PVC details

pvc=$(kubectl get pvc $pvc_name -n $namespace -o json)

# Check if the PVC is in a failed state

if [[ $(echo $pvc | jq -r '.status.phase') == "Failed" ]]; then

  echo "The PVC '$pvc_name' in namespace '$namespace' is in a failed state."

  # Get the events for the PVC

  events=$(kubectl get events -n $namespace --field-selector involvedObject.kind=PersistentVolumeClaim,involvedObject.name=$pvc_name -o json)

  # Check if there are any events for the PVC

  if [[ $(echo $events | jq -r '.items | length') == 0 ]]; then

    echo "There are no events for the PVC '$pvc_name' in namespace '$namespace'."

  else

    # Print the events for the PVC

    echo "Events for the PVC '$pvc_name' in namespace '$namespace':"

    echo $events | jq -r '.items[] | .lastTimestamp + " " + .reason + " " + .message'

  fi

else

  echo "The PVC '$pvc_name' in namespace '$namespace' is not in a failed state."

fi

```
### Check the storage class and ensure that it is correctly configured and able to provide the requested storage.
```shell
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


```

## Repair

### Check the storage provisioner and ensure that it is correctly configured and running.
```shell

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


```
### Recreates Failed Persistent Volume Claims.
```shell

kubectl get pvc $PVC_NAME -o name | xargs kubectl delete

```