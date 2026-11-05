#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REGION=ap-south-1
CLUSTER=skill-job-matcher-eks

cd "$ROOT/infra"
terraform init -input=false -backend-config=backend.hcl
terraform apply -input=false -auto-approve

aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER" >/dev/null
kubectl wait --for=condition=Ready nodes --all --timeout=300s

SECRET_ARN="$(terraform output -raw rds_secret_arn)"
aws secretsmanager get-secret-value --secret-id "$SECRET_ARN" --query SecretString --output text \
  | python3 -c 'import sys,json; sys.stdout.write(json.load(sys.stdin)["password"])' \
  | kubectl create secret generic db-credentials --from-file=DB_PASSWORD=/dev/stdin --dry-run=client -o yaml \
  | kubectl apply -f -
kubectl create configmap db-init --from-file=init.sql="$ROOT/db/init.sql" --dry-run=client -o yaml | kubectl apply -f -

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts >/dev/null 2>&1 || true
helm repo update >/dev/null
GRAFANA_PW="$(openssl rand -base64 18 | tr -d '/+=')"
helm upgrade --install kps prometheus-community/kube-prometheus-stack \
  --version "92.10.1" \
  --namespace monitoring --create-namespace \
  -f "$ROOT/monitoring/values.yaml" \
  --set grafana.adminPassword="$GRAFANA_PW" \
  --wait --timeout 10m

echo "up done. Now run the pipeline (git push or Run workflow in Actions)."
