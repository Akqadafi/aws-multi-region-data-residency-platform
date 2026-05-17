#!/usr/bin/env bash
set -euo pipefail

TS=$(date +"%Y-%m-%d_%H%M")
DIR="artifacts/$TS"
mkdir -p "$DIR"

echo "==> Evidence capture: $DIR"

# Terraform hygiene
terraform fmt -check > "$DIR/fmt.txt" 2>&1 || true
terraform validate > "$DIR/validate.txt" 2>&1 || true

# Plan (intent)
terraform plan -out=tfplan > "$DIR/plan.txt" 2>&1 || true
terraform show -json tfplan > "$DIR/plan.json" 2>&1 || true

# Outputs (reality snapshot, best effort)
terraform output -json > "$DIR/outputs.json" 2>&1 || true

# Optional linting (if installed)
if command -v tflint >/dev/null 2>&1; then
  tflint > "$DIR/tflint.txt" 2>&1 || true
else
  echo "tflint not installed" > "$DIR/tflint.txt"
fi

# Notes stub (human reasoning)
cat > "$DIR/notes.md" <<EOF
# Notes ($TS)

## What changed?
-

## What did you expect?
-

## What actually happened?
-

## If something failed, what error?
-

## Hypothesis / fix
-
EOF

echo "==> Done: $DIR"