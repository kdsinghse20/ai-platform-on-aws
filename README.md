# AI Platform on AWS

Production-style deployment of a self-hosted AI Platform using **Terraform**, **Ansible**, **AWS**, **Ollama**, **OpenWebUI**, **NGINX**, and an **Application Load Balancer**.

The project demonstrates Infrastructure as Code (IaC), Configuration Management, and Platform Engineering best practices by deploying an AI chatbot platform inside a secure AWS VPC without exposing compute instances directly to the internet.

---

## Architecture Overview

Users
   │
HTTPS
   │
Route53
   │
AWS ACM Certificate
   │
Application Load Balancer
   │
NGINX Reverse Proxy
   │
OpenWebUI
   │
Private Network
   │
Ollama
   │
Gemma 3 Model
   |
llama3.2 Model   


## Features

- Infrastructure managed using Terraform
- Modular Terraform architecture
- Configuration managed using Ansible
- AWS Systems Manager (SSM) for server management
- No SSH access required
- Private EC2 instances
- OpenWebUI deployment
- Ollama deployment
- Automatic model installation
- NGINX reverse proxy
- HTTPS using ACM
- Route53 DNS integration
- Application Load Balancer
- Security Group isolation
- IAM least privilege

## Technology Stack

| Category | Technology |
|-----------|------------|
| Cloud | AWS |
| IaC | Terraform |
| Configuration | Ansible |
| Reverse Proxy | NGINX |
| AI Runtime | Ollama |
| UI | OpenWebUI |
| OS | Ubuntu 24.04 |
| Load Balancer | AWS ALB |
| DNS | Route53 |
| SSL | AWS ACM |
| Access | AWS SSM |

## Deployment Flow

terraform init

↓

terraform apply

↓

Ansible Common Role

↓

Ollama Installation

↓

OpenWebUI Installation

↓

NGINX Configuration

↓

ALB

↓

Route53

↓

HTTPS Ready

## Project Structure

ai-platform-on-aws/

├── terraform/
│   ├── environments/
│   ├── modules/
│   │   ├── vpc/
│   │   ├── ec2/
│   │   ├── iam/
│   │   ├── alb/
│   │   └── security-groups/
│
├── ansible/
│   ├── inventory/
│   ├── playbooks/
│   └── roles/
│       ├── common/
│       ├── ollama/
│       ├── openwebui/
│       └── nginx/
│
├── docs/
└── README.md

## Deployment Flow ##

### Deploy

### Clone Repository

git clone ...

### Deploy Infrastructure

terraform init

terraform apply

### Configure Servers

ansible-playbook playbooks/site.yml


## Future Improvements

- GPU instances
- Auto Scaling
- Crossplane
- Backstage
- CI/CD
- GitHub Actions
- Monitoring (Grafana + Prometheus)
- Loki
- EFS Model Storage
- Multi-region deployment