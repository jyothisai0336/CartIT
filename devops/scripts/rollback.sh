#!/usr/bin/env bash
set -euo pipefail
ENV=${1:-dev}; AWS_REGION="ap-south-1"
echo "⚠️  Rolling back CartIt on ${ENV}..."
aws eks update-kubeconfig --name "cartit-${ENV}" --region "${AWS_REGION}"
kubectl rollout undo deployment/cartit-frontend --namespace cartit
kubectl rollout status deployment/cartit-frontend --namespace cartit --timeout=5m
echo "✅ Rollback complete"
