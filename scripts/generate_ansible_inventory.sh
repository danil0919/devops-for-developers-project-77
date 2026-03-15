#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TERRAFORM_DIR="$ROOT_DIR/terraform"
ANSIBLE_DIR="$ROOT_DIR/ansible"
INVENTORY_FILE="$ANSIBLE_DIR/inventory.ini"

mkdir -p "$ANSIBLE_DIR"

TF_JSON="$(cd "$TERRAFORM_DIR" && terraform output -json)"

postgres_ip="$(echo "$TF_JSON" | jq -r '.postgres_ip.value')"
postgres_private_ip="$(echo "$TF_JSON" | jq -r '.postgres_private_ip.value')"
focalboard1_ip="$(echo "$TF_JSON" | jq -r '.focalboard1_ip.value')"
focalboard2_ip="$(echo "$TF_JSON" | jq -r '.focalboard2_ip.value')"
load_balancer_ip="$(echo "$TF_JSON" | jq -r '.load_balancer_ip.value')"

cat > "$INVENTORY_FILE" <<EOF
[postgres]
postgres-1 ansible_host=$postgres_ip ansible_user=ubuntu private_ip=$postgres_private_ip

[focalboard]
focalboard-1 ansible_host=$focalboard1_ip ansible_user=ubuntu
focalboard-2 ansible_host=$focalboard2_ip ansible_user=ubuntu

[all:vars]
ansible_python_interpreter=/usr/bin/python3
postgres_private_ip=$postgres_private_ip
load_balancer_ip=$load_balancer_ip
EOF

echo "Generated $INVENTORY_FILE"
cat "$INVENTORY_FILE"