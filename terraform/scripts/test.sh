#!/usr/bin/env bash
# =============================================================================
# scripts/test.sh
# Validates and plans all three environments WITHOUT applying.
# Safe to run at any time — makes no changes to your system.
#
# Checks:
#   1. terraform fmt     — formatting
#   2. terraform validate — configuration correctness
#   3. terraform plan    — for dev, staging, prod (output only, not applied)
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_DIR="$(dirname "$SCRIPT_DIR")"

echo "==> Changing to terraform directory: $TF_DIR"
cd "$TF_DIR"

# ---- 1. Format check --------------------------------------------------------
echo ""
echo "========================================"
echo " STEP 1: Formatting check (terraform fmt)"
echo "========================================"
if terraform fmt -check -recursive; then
  echo "PASS: All files are correctly formatted."
else
  echo "FAIL: Formatting issues found. Run 'terraform fmt -recursive' to fix."
  exit 1
fi

# ---- 2. Validate ------------------------------------------------------------
echo ""
echo "========================================"
echo " STEP 2: Configuration validation"
echo "========================================"
# Select dev workspace just to have a workspace active for validation
terraform workspace select dev 2>/dev/null || true
terraform validate
echo "PASS: Configuration is valid."

# ---- 3. Plan per environment ------------------------------------------------
ENVIRONMENTS=("dev" "staging" "prod")

for ENV in "${ENVIRONMENTS[@]}"; do
  echo ""
  echo "========================================"
  echo " STEP 3-${ENV}: terraform plan for '$ENV'"
  echo "========================================"

  terraform workspace select "$ENV"
  echo "Active workspace: $(terraform workspace show)"

  terraform plan \
    -var-file="envs/${ENV}.tfvars" \
    -detailed-exitcode \
    -out="/dev/null" \
    2>&1 | tail -20

  echo "PASS: Plan succeeded for '$ENV'."
done

# ---- Summary ----------------------------------------------------------------
echo ""
echo "========================================"
echo " ALL CHECKS PASSED"
echo "========================================"
echo ""
echo "  Workspace state files will be at:"
echo "    state/terraform.tfstate.d/dev/terraform.tfstate"
echo "    state/terraform.tfstate.d/staging/terraform.tfstate"
echo "    state/terraform.tfstate.d/prod/terraform.tfstate"
echo ""
echo "  To deploy an environment:"
echo "    ./scripts/apply.sh dev"
echo "    ./scripts/apply.sh staging"
echo "    ./scripts/apply.sh prod"
