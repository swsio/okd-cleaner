#!/bin/sh
# Fix for kubectl errors 
mkdir -p /tmp/.kube/
touch /tmp/.kube/config
export KUBECONFIG=/tmp/.kube/config

# Login with SA
oc login --token=`cat /var/run/secrets/kubernetes.io/serviceaccount/token` https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT --insecure-skip-tls-verify

# Delete failed Pods
oc delete pod --field-selector=status.phase==Failed --all-namespaces > /tmp/pods

# Delete failed Jobs
oc get job -n openshift-logging -o=jsonpath='{.items[?(@.status.failed==1)].metadata.name}' > /tmp/jobsfailed
LINECOUNTFAILEDJOBS=`oc get job -n openshift-logging -o=jsonpath='{.items[?(@.status.failed==1)].metadata.name}' |wc| awk '{print $2}'`
if [ $LINECOUNTFAILEDJOBS -gt 1 ]; then
    oc delete job -n openshift-logging $(oc get job -n openshift-logging -o=jsonpath='{.items[?(@.status.failed==1)].metadata.name}') > /tmp/jobs
    echo "No Jobs found, nothing to do!"
else
    echo "No failed Jobs found"
fi

# Cleanup Output
LINECOUNT=`wc -l /tmp/pods | awk '{print $1}'`
if [ $LINECOUNT -gt 1 ]; then
    echo "Cleaned Pods!"
else
    echo "No Pods found, nothing to do!"
fi
