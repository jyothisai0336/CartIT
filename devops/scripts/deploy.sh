#!/usr/bin/env bash
set -euo pipefail
ENV=${1:-dev}; IMAGE_TAG=${2:-latest}; AWS_REGION="ap-south-1"
echo "🚀 Deploying CartIt to ${ENV} — ${IMAGE_TAG}"
aws eks update-kubeconfig --name "cartit-${ENV}" --region "${AWS_REGION}"
cd "devops/kubernetes/overlays/${ENV}"
kustomize edit set image "ACCOUNT_ID.dkr.ecr.${AWS_REGION}.amazonaws.com/cartit-frontend:${IMAGE_TAG}"
kustomize build . | kubectl apply -f -
kubectl rollout status deployment/cartit-frontend --namespace cartit --timeout=10m
echo "✅ Deploy complete — ${ENV} @ ${IMAGE_TAG}"
