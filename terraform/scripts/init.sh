#!/usr/bin/env bash
# =============================================================================
# scripts/init.sh
# One-time setup: initialise Terraform and create the three workspaces.
# Run this ONCE before anything else.
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_DIR="$(dirname "$SCRIPT_DIR")"

echo "==> Changing to terraform directory: $TF_DIR"
cd "$TF_DIR"

echo ""
echo "==> terraform init (downloads providers: kreuzwerker/docker, scott-the-k8s-ranger/minikube)"
terraform init

echo ""
echo "==> Creating workspaces (dev, staging, prod)"
for ws in dev staging prod; do
  if terraform workspace list | grep -qw "$ws"; then
    echo "    workspace '$ws' already exists — skipping"
  else
    terraform workspace new "$ws"
    echo "    created workspace '$ws'"
  fi
done

echo ""
echo "==> Switching back to 'dev' workspace (most common starting point)"
terraform workspace select dev

echo ""
echo "==> Current workspaces:"
terraform workspace list

echo ""
echo "Done! Next steps:"
echo "  Deploy dev:     ./scripts/apply.sh dev"
echo "  Deploy staging: ./scripts/apply.sh staging"
echo "  Deploy prod:    ./scripts/apply.sh prod"
