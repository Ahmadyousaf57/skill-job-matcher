#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

helm uninstall skill 2>/dev/null || echo "helm release skill not found, continuing"
helm uninstall kps -n monitoring 2>/dev/null || true
for i in $(seq 1 20); do
  [ -z "$(aws elb describe-load-balancers --query 'LoadBalancerDescriptions[].LoadBalancerName' --output text)" ] && break
  sleep 15
done

cd "$ROOT/infra"
terraform destroy -input=false -auto-approve

echo "--- leftovers (should all be empty) ---"
aws eks list-clusters --query clusters --output text
aws rds describe-db-instances --query 'DBInstances[].DBInstanceIdentifier' --output text
aws ec2 describe-nat-gateways --filter Name=state,Values=available,pending --query 'NatGateways[].NatGatewayId' --output text
aws elb describe-load-balancers --query 'LoadBalancerDescriptions[].LoadBalancerName' --output text
aws ec2 describe-volumes --query 'Volumes[].VolumeId' --output text
aws ec2 describe-addresses --query 'Addresses[].PublicIp' --output text
