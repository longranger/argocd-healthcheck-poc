#!/usr/bin/env bash

set -e

echo "🔥 Tearing down ArgoCD..."

# Find and kill the port-forward process if it's running
PID=$(ps aux | grep "kubectl port-forward svc/argocd-server" | grep -v grep | awk '{print $2}')
if [ -n "$PID" ]; then
  echo "🔪 Killing port-forward process (PID: $PID)..."
  kill $PID
fi

# Uninstall the helm release and delete the namespace
helm uninstall argocd --namespace argocd
kubectl delete namespace argocd

echo "✅ Teardown complete."
