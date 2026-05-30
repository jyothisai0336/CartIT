# 🛒 CartIt India — Production Monorepo

India's large-scale e-commerce supermarket. Built for thousands of concurrent users.

## Structure
```
cartit-prod/
├── app/          ← React frontend (CartIt India)
└── devops/       ← All infrastructure & CI/CD
    ├── docker/
    ├── terraform/
    ├── kubernetes/
    ├── jenkins/
    ├── monitoring/
    ├── security/
    └── scripts/
```

## Quick Start
```bash
# 1. Configure AWS
aws configure

# 2. Provision infrastructure
cd devops/terraform/environments/prod
terraform init && terraform apply

# 3. Deploy app via Jenkins pipeline (auto-triggered on git push)
git push origin main
```

## Tech Stack
| Layer | Technology |
|---|---|
| Frontend | React 18, Outfit font, Glassmorphism UI |
| Container | Docker (multi-stage), nginx:alpine |
| Registry | Amazon ECR |
| Orchestration | Amazon EKS (Kubernetes 1.29) |
| IaC | Terraform 1.6+ |
| CI/CD | Jenkins Declarative Pipeline |
| SAST | SonarQube 10 |
| Container Scan | Trivy |
| Database | Aurora PostgreSQL 15 |
| Cache | ElastiCache Redis 7 |
| CDN | CloudFront + WAFv2 |
| Secrets | AWS Secrets Manager + External Secrets Operator |
| Monitoring | Prometheus + Grafana + Alertmanager |

## Environments
| Env | Branch | Cluster | URL |
|---|---|---|---|
| Dev | develop | cartit-dev | dev.cartit.in |
| Staging | staging | cartit-staging | staging.cartit.in |
| Prod | main | cartit-prod | cartit.in |
