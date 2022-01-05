#!/bin/sh 
mkdir -p /tmp/.kube/
touch /tmp/.kube/config
export KUBECONFIG=/tmp/.kube/config
oc login --token=`cat /var/run/secrets/kubernetes.io/serviceaccount/token` https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT --insecure-skip-tls-verify
oc delete pod --field-selector=status.phase==Failed --all-namespaces > /tmp/pods
oc delete job -n openshift-logging $(oc get job -n openshift-logging -o=jsonpath='{.items[?(@.status.failed==1)].metadata.name}') > /tmp/jobs
LINECOUNT=`wc -l /tmp/pods | awk '{print $1}'`
LINECOUNTJOBS=`wc -l /tmp/jobs | awk '{print $1}'`
if [ $LINECOUNT -gt 1 ]; then
    echo "Cleaned Pods!"
else
    echo "No Pods found, nothing to do!"
if [ $LINECOUNTJOBS -gt 1 ]; then
    echo "Cleaned Jobs!"
else
    echo "No Jobs found, nothing to do!"
fi
