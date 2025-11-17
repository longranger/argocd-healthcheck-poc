#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "🚀 Starting ArgoCD Bootstrap..."

# 1. Clean Slate
echo "🔄 Ensuring a clean environment..."
pgrep -f "kubectl port-forward svc/argocd-server" | xargs -r kill
helm uninstall argocd --namespace argocd &> /dev/null || true
kubectl delete namespace argocd --ignore-not-found=true

# 2. Install ArgoCD using the chart's default settings
echo "📦 Installing ArgoCD..."
kubectl create namespace argocd
helm repo add argo https://argoproj.github.io/argo-helm > /dev/null
helm repo update > /dev/null

# Install with no password overrides. Let the chart generate the secret.
helm install argocd argo/argo-cd \
  --namespace argocd \
  -f argocd-health-check-values.yaml \
  --wait

# 3. Retrieve the auto-generated password
echo "🔑 Retrieving initial admin password..."
# This is the guaranteed way to get the correct password.
ADMIN_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

# 4. Start Port-Forwarding
echo "🌐 Starting port-forward in the background..."
nohup kubectl port-forward svc/argocd-server -n argocd 8080:443 >/dev/null 2>&1 &
PORT_FORWARD_PID=$!

# 5. Deploy the Root Application
echo "🚀 Deploying the root application..."
kubectl apply -f apps/root.yaml

echo ""
echo "✅ ArgoCD is ready!"
echo "--------------------------------------------------------"
echo "URL:      https://localhost:8080"
echo "Username: admin"
echo "Password: ${ADMIN_PASSWORD}"
echo "--------------------------------------------------------"
echo "Port-forward has been started in the background (PID: ${PORT_FORWARD_PID})."
echo "To stop it, run: kill ${PORT_FORWARD_PID}"
echo ""
