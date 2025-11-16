# Goal: Prove ArgoCD Custom Health Checks with a Helm-based App-of-Apps Pattern

We will create a GitOps repository to deploy a set of applications onto a Kubernetes cluster using ArgoCD. The primary goal is to simulate a dependency issue (like the Karpenter/Calico problem) and solve it using a custom ArgoCD health check. The entire setup will be managed via Helm charts.

# Context

*   **Kubernetes Cluster:** 3-node Talos cluster on Proxmox. (1 control plane, 2 workers).
*   **GitOps Tool:** ArgoCD.
*   **Packaging:** Everything will be managed with Helm.
*   **Existing State:** ArgoCD is already installed via `bootstrap-argo.sh`
*   **Tools:** This directory should have access to talosctl, kubectl, helm, k9s, argocd.
*   **Repo:** git remote of this directory is also public: https://github.com/longranger/argocd-healthcheck-poc.git
*   **The Problem to Simulate:** We need two applications. App B depends on App A. ArgoCD's default health checks will report App A as "Healthy" before it's truly ready for connections, causing App B to fail.
*   **The Solution to Implement:** We will write a custom Lua health check for App A to ensure ArgoCD waits until it is fully operational before proceeding to sync App B.

# File Structure

We will adopt a standard GitOps repository layout:

```mermaid
├── apps/ # ArgoCD Application manifests
│ ├── root.yaml
│ └── templates/
├── charts/ # Our local Helm charts
│ ├── app-a/
│ └── app-b/
├── .gitignore
└── GEMINI.md
```

# Plan

1.  **ArgoCD Installation:** We will first install ArgoCD onto the cluster using the official Helm chart. We'll do this manually with `helm` commands, as it's a one-time bootstrap.
2.  **App-of-Apps Setup:** Create a "root" ArgoCD application (`apps/root.yaml`) that will manage all other applications in the cluster.
3.  **Create App A:** Develop a simple Helm chart for a stateful service, like a database (e.g., Redis). This will be `charts/app-a`.
4.  **Create App B:** Develop a simple Helm chart for a stateless application that depends on App A. This will be `charts/app-b`.
5.  **Demonstrate the Problem:** Deploy both apps using ArgoCD and observe App B failing.
6.  **Implement the Fix:** Add a custom health check for App A to the ArgoCD configuration and prove that it resolves the dependency issue.
