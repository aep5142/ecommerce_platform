#!/usr/bin/env bash
# =============================================================================
# scripts/apply.sh <environment>
# Select the workspace and apply the matching .tfvars file.
#
# Usage:
#   ./scripts/apply.sh dev
#   ./scripts/apply.sh staging
#   ./scripts/apply.sh prod
# =============================================================================
set -euo pipefail

ENV="${1:-}"
if [[ -z "$ENV" ]]; then
  echo "ERROR: environment argument required."
  echo "Usage: $0 <dev|staging|prod>"
  exit 1
fi

if [[ "$ENV" != "dev" && "$ENV" != "staging" && "$ENV" != "prod" ]]; then
  echo "ERROR: environment must be 'dev', 'staging', or 'prod' (got: '$ENV')"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_DIR="$(dirname "$SCRIPT_DIR")"
TFVARS="$TF_DIR/envs/${ENV}.tfvars"

echo "==> Changing to terraform directory: $TF_DIR"
cd "$TF_DIR"

echo "==> Selecting workspace: $ENV"
terraform workspace select "$ENV"

echo "==> Running terraform plan with envs/${ENV}.tfvars"
terraform plan -var-file="$TFVARS" -out="plan-${ENV}.tfplan"

echo ""
read -r -p "Apply the plan for '$ENV'? [y/N] " confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
  echo "==> Applying..."
  terraform apply "plan-${ENV}.tfplan"
  rm -f "plan-${ENV}.tfplan"

  echo ""
  echo "==> Outputs for '$ENV':"
  terraform output service_summary
else
  echo "Apply cancelled. Plan file saved at: plan-${ENV}.tfplan"
fi
