#!/bin/sh 
export KUBECONFIG=/tmp/.kube/config
oc login --token=`cat /var/run/secrets/kubernetes.io/serviceaccount/token` https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT --insecure-skip-tls-verify
oc get csr -o go-template='{{range .items}}{{if not .status}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}' > /tmp/csrs
LINECOUNT=`wc -l /tmp/csrs | awk '{print $1}'`
if [ $LINECOUNT -gt 0 ]; then
    cat /tmp/csrs | xargs oc adm certificate approve
else
    echo "No CSRs found, nothing to do!"
fi
