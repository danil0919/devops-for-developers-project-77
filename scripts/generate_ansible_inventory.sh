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
load_balancer_ip="$(echo "$TF_JSON" | jq -r '.load_balancer_ip.value')"

cat > "$INVENTORY_FILE" <<EOF
[postgres]
postgres-1 ansible_host=$postgres_ip ansible_user=ubuntu

[focalboard]
EOF

echo "$TF_JSON" | jq -r '.focalboard_ips.value[]' | nl -v1 -w1 -s' ' | while read -r idx ip; do
  echo "focalboard-$idx ansible_host=$ip ansible_user=ubuntu" >> "$INVENTORY_FILE"
done

cat >> "$INVENTORY_FILE" <<EOF

[all:vars]
ansible_python_interpreter=/usr/bin/python3
postgres_host=$postgres_private_ip
load_balancer_ip=$load_balancer_ip
EOF

echo "Generated $INVENTORY_FILE"
cat "$INVENTORY_FILE"