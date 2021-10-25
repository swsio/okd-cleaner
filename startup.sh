#!/bin/sh 
export KUBECONFIG=/tmp/.kube/config
oc login --token=`cat /var/run/secrets/kubernetes.io/serviceaccount/token` https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT --insecure-skip-tls-verify
oc delete pod --field-selector=status.phase==Failed --all-namespaces > /tmp/pods
LINECOUNT=`wc -l /tmp/pods | awk '{print $1}'`
if [ $LINECOUNT -gt 0 ]; then
    echo "Cleaned Pods!"
else
    echo "No Pods found, nothing to do!"
fi
