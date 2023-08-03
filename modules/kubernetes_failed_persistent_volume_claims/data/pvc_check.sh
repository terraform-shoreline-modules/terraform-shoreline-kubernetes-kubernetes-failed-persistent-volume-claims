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