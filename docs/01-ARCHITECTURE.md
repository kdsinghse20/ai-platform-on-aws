# System Architecture & Design

**Complete architectural overview of the AI Platform deployment.**

---

## System Overview

This document describes the complete system design. For visual diagrams, see the `diagrams/` folder.

---

## Architecture Components

### High-Level Flow

```
Users (HTTPS)
  ↓
Route53 DNS
  ↓
AWS ALB (Application Load Balancer)
  ↓
NGINX Reverse Proxy (OpenWebUI instance)
  ↓
OpenWebUI Web Application
  ↓
Ollama AI Runtime (Ollama instance)
  ↓
AI Models (Gemma 3, Llama 3.2)
```

### Component Tiers

**Tier 1 - Public (Internet-Facing)**
- Application Load Balancer (ALB)
- Located in public subnets
- HTTPS/TLS termination
- Route 53 DNS resolution

**Tier 2 - Private App (Application)**
- OpenWebUI EC2 instance
- NGINX reverse proxy
- Located in private app subnets
- Access only from ALB

**Tier 3 - Private AI (AI Runtime)**
- Ollama EC2 instance  
- AI model execution
- Located in private AI subnets
- Access only from OpenWebUI

---

## Network Architecture

### VPC Structure

- **VPC CIDR**: 10.0.0.0/16
- **Public Subnets**: 10.0.1.0/24, 10.0.2.0/24
- **Private App Subnets**: 10.0.10.0/24, 10.0.11.0/24
- **Private AI Subnets**: 10.0.20.0/24, 10.0.21.0/24
- **Multi-AZ**: Distributed across 2 availability zones

### Security Architecture

- **No public IPs** on compute instances
- **Security Groups** restrict traffic
- **NAT Gateways** for outbound internet
- **IAM Roles** with least privilege
- **TLS/HTTPS** for all external communication

For detailed security architecture, see `diagrams/05-security-groups.txt`.

---

## Deployment Overview

See `diagrams/04-deployment-sequence.txt` for visual deployment flow.

### Phase 1: Infrastructure (Terraform)
Creates AWS infrastructure (~15-20 minutes)

### Phase 2: Configuration (Ansible)  
Configures services (~30-50 minutes)

### Phase 3: Verification
Tests all components (~5-10 minutes)

---

## Dependencies

**Infrastructure**:
1. VPC (base)
2. Security Groups (requires VPC)
3. IAM (independent)
4. EC2 (requires VPC, SG, IAM)
5. ALB (requires VPC, SG, EC2)

**Services**:
1. Common Role (base)
2. Ollama Role (requires common)
3. OpenWebUI Role (requires common, Ollama)
4. NGINX Role (requires common, OpenWebUI)

---

## Detailed Documentation

For detailed information about specific components:
- **VPC & Networking**: `terraform/01-VPC.md`
- **Security Groups**: `terraform/02-SECURITY_GROUPS.md`
- **IAM & Permissions**: `terraform/03-IAM.md`
- **EC2 Instances**: `terraform/04-EC2.md`
- **Load Balancer**: `terraform/05-ALB.md`
- **Ollama Configuration**: `ansible/02-OLLAMA_ROLE.md`
- **OpenWebUI Setup**: `ansible/03-OPENWEBUI_ROLE.md`
- **NGINX Proxy**: `ansible/04-NGINX_ROLE.md`

---

**Last Updated**: August 3, 2026 | **Version**: 1.0
