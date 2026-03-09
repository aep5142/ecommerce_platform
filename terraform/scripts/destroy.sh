#!/usr/bin/env bash
# =============================================================================
# scripts/destroy.sh <environment>
# Tear down all resources for the given environment.
#
# Usage:
#   ./scripts/destroy.sh dev
#   ./scripts/destroy.sh staging
#   ./scripts/destroy.sh prod
# =============================================================================
set -euo pipefail

ENV="${1:-}"
if [[ -z "$ENV" ]]; then
  echo "ERROR: environment argument required."
  echo "Usage: $0 <dev|staging|prod>"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_DIR="$(dirname "$SCRIPT_DIR")"
TFVARS="$TF_DIR/envs/${ENV}.tfvars"

echo "==> Changing to terraform directory: $TF_DIR"
cd "$TF_DIR"

echo "==> Selecting workspace: $ENV"
terraform workspace select "$ENV"

echo ""
echo "WARNING: This will DESTROY all Docker containers, networks, and volumes"
echo "         for the '$ENV' environment."
echo ""
read -r -p "Are you sure you want to destroy '$ENV'? [y/N] " confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
  terraform destroy -var-file="$TFVARS" -auto-approve
  echo "==> '$ENV' environment destroyed."
else
  echo "Destroy cancelled."
fi
