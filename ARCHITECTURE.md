# AI Platform Architecture & Dependency Guide

## Overview

This document provides a complete architectural view of the AI Platform deployment, including component interactions, data flow, and dependencies.

---

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                          Users / External Traffic                    │
└────────────────────────────────┬────────────────────────────────────┘
                                 │
                    ┌────────────▼────────────┐
                    │      Route53 (DNS)      │
                    └────────────┬────────────┘
                                 │
                    ┌────────────▼────────────┐
                    │   ACM SSL Certificate   │
                    └────────────┬────────────┘
                                 │
        ┌───────────────────────▼──────────────────────┐
        │  AWS Application Load Balancer (Public)       │
        │  - Terminates HTTPS/TLS                       │
        │  - Routes traffic to NGINX                    │
        │  - Located in Public Subnets                  │
        └───────────────────────┬──────────────────────┘
                                 │
        ┌────────────────────────▼──────────────────────┐
        │           AWS VPC (10.0.0.0/16)               │
        │                                                │
        │ ┌──────────────────────────────────────────┐  │
        │ │  PUBLIC SUBNETS (10.0.1.0/24, 10.0.2.0/24)  │
        │ │  - Internet Gateway attached                │
        │ │  - NAT Gateways for outbound traffic       │
        │ └──────────────────────────────────────────┘  │
        │                                                │
        │ ┌──────────────────────────────────────────┐  │
        │ │  PRIVATE APP SUBNETS (10.0.10.0/24, 11)    │
        │ │  ┌────────────────────────────────────┐  │  │
        │ │  │ OpenWebUI EC2 Instance (t3.large)  │  │  │
        │ │  │ - NGINX Reverse Proxy               │  │  │
        │ │  │ - OpenWebUI Application             │  │  │
        │ │  │ - SSM Session Manager Access        │  │  │
        │ │  │ - No Direct Internet Exposure       │  │  │
        │ │  └────────────────────────────────────┘  │  │
        │ └──────────────────────────────────────────┘  │
        │                      │                         │
        │                      │ (Private Network)       │
        │                      ▼                         │
        │ ┌──────────────────────────────────────────┐  │
        │ │  PRIVATE AI SUBNETS (10.0.20.0/24, 21)     │
        │ │  ┌────────────────────────────────────┐  │  │
        │ │  │ Ollama EC2 Instance (t3.large)     │  │  │
        │ │  │ - Ollama Runtime                    │  │  │
        │ │  │ - Gemma 3 Model                     │  │  │
        │ │  │ - Llama 3.2 Model                   │  │  │
        │ │  │ - Model Management                  │  │  │
        │ │  │ - SSM Session Manager Access        │  │  │
        │ │  │ - No Direct Internet Access         │  │  │
        │ │  └────────────────────────────────────┘  │  │
        │ └──────────────────────────────────────────┘  │
        │                                                │
        └────────────────────────────────────────────────┘
```

---

## Component Interaction Flow

### 1. **User Request Flow**

```
User Browser
    ↓
HTTPS Request (Route53 DNS)
    ↓
AWS ALB (Public Subnet)
    ↓
NGINX Reverse Proxy (Private App Subnet)
    ↓
OpenWebUI Application
    ↓
Ollama API (Private AI Subnet)
    ↓
AI Models (Gemma 3, Llama 3.2)
    ↓
Response → OpenWebUI → NGINX → ALB → User
```

### 2. **Deployment Flow**

```
Terraform Init
    ↓
    ├─→ VPC Module (Network Infrastructure)
    ├─→ Security Groups Module (Network Access Control)
    ├─→ IAM Module (Service Accounts & Permissions)
    ├─→ EC2 Module × 2 (OpenWebUI & Ollama Instances)
    └─→ ALB Module (Load Balancer & DNS)
    ↓
EC2 Instances Launched
    ↓
Ansible Provisioning
    ├─→ Common Role (System Setup)
    ├─→ Ollama Role (Install & Configure)
    ├─→ OpenWebUI Role (Install & Configure)
    └─→ NGINX Role (Reverse Proxy Setup)
    ↓
Infrastructure Ready
```

---

## Dependency Map

### **Infrastructure Dependencies**

```
ALB Module
    ↓
    └─→ Requires: VPC, Security Groups, EC2 (OpenWebUI)

EC2 Modules (OpenWebUI & Ollama)
    ↓
    └─→ Requires: VPC, Security Groups, IAM

Security Groups Module
    ↓
    └─→ Requires: VPC

IAM Module
    ↓
    └─→ Independent (AWS Account Level)

VPC Module
    ↓
    └─→ Base Infrastructure (No Dependencies)
```

### **Configuration Dependencies**

```
Ansible Playbooks (site.yml)
    ↓
    ├─→ common.yml (Run First - System Setup)
    ├─→ ollama.yml (Run Second - AI Runtime)
    ├─→ openwebui.yml (Run Third - Web UI)
    └─→ nginx.yml (Run Fourth - Reverse Proxy)

OpenWebUI Role
    ↓
    └─→ Depends On: common role (system dependencies)

Ollama Role
    ↓
    └─→ Depends On: common role (system dependencies)

NGINX Role
    ↓
    └─→ Depends On: common role (system dependencies)
```

---

## Network Architecture Details

### **VPC Subnets Structure**

| Subnet Type | CIDR Range | Count | Availability | Purpose |
|---|---|---|---|---|
| **Public** | 10.0.1.0/24, 10.0.2.0/24 | 2 | Multiple AZs | Internet Gateway, ALB, NAT Gateways |
| **Private App** | 10.0.10.0/24, 10.0.11.0/24 | 2 | Multiple AZs | OpenWebUI EC2 Instance |
| **Private AI** | 10.0.20.0/24, 10.0.21.0/24 | 2 | Multiple AZs | Ollama EC2 Instance |

### **Security Group Rules**

#### **ALB Security Group**
- **Inbound**: 
  - Port 80 (HTTP) from 0.0.0.0/0 → Redirect to HTTPS
  - Port 443 (HTTPS) from 0.0.0.0/0 → Valid requests only
- **Outbound**: All traffic to OpenWebUI SG (Port 80)

#### **OpenWebUI Security Group**
- **Inbound**: 
  - Port 80 from ALB SG
  - Port 22 from AWS Systems Manager (SSM)
- **Outbound**: 
  - Port 11434 to Ollama SG (Ollama API)
  - Port 443 to 0.0.0.0/0 (External APIs if needed)

#### **Ollama Security Group**
- **Inbound**: 
  - Port 11434 from OpenWebUI SG (API requests)
  - Port 22 from AWS Systems Manager (SSM)
- **Outbound**: 
  - Port 443 to 0.0.0.0/0 (Model downloads, updates)

---

## Access Control Strategy

### **No SSH - AWS Systems Manager Approach**

All EC2 instances are **private** with no SSH access:
- **Access Method**: AWS Systems Manager Session Manager
- **Requirements**: 
  - EC2 instance has IAM role with SSM permissions
  - User has IAM permission for `ssm:StartSession`
  - No security group rules for SSH (port 22) from public internet

### **IAM Permissions**

- **EC2 Instance Profile**: Attached to all instances
  - Allows: CloudWatch Logs, Systems Manager Session Manager
  - Scope: Specific to service role only
- **Least Privilege**: Only required permissions granted

---

## Data Flow & Communication

### **Secure Communication Paths**

```
1. External Communication:
   User → HTTPS → Route53 → ALB → NGINX (HTTP locally)

2. Internal Communication:
   NGINX → HTTP (Port 80) → OpenWebUI
   OpenWebUI → HTTP (Port 11434) → Ollama API

3. Model Downloads:
   Ollama → HTTPS (Port 443) → Model Registry
```

### **No Direct Internet Access**

- OpenWebUI & Ollama instances are in **private subnets**
- Outbound internet access via **NAT Gateways**
- No public IP addresses assigned
- SSM Session Manager provides secure shell access

---

## Component Specifications

### **EC2 Instances**

| Instance | Subnet Type | Instance Type | OS | Purpose |
|---|---|---|---|---|
| **OpenWebUI** | Private App | t3.large | Ubuntu 24.04 | Web UI & NGINX |
| **Ollama** | Private AI | t3.large | Ubuntu 24.04 | AI Model Runtime |

### **Key Services**

| Service | Instance | Port | Protocol | Purpose |
|---|---|---|---|---|
| **NGINX** | OpenWebUI | 80 | HTTP | Reverse Proxy |
| **OpenWebUI** | OpenWebUI | 8080 | HTTP (Internal) | Web Interface |
| **Ollama** | Ollama | 11434 | HTTP | Model API |

---

## Deployment Checklist

### **Pre-Deployment**

- [ ] AWS Account configured with appropriate permissions
- [ ] Terraform backend (S3, DynamoDB) created
- [ ] ACM certificate created for domain
- [ ] Route53 hosted zone created

### **Terraform Phase**

- [ ] Run `terraform init` → Initialize backend
- [ ] Run `terraform plan` → Review changes
- [ ] Run `terraform apply` → Create infrastructure
- [ ] Verify EC2 instances are running
- [ ] Verify ALB is created and active
- [ ] Generate Ansible inventory from Terraform outputs

### **Ansible Phase**

- [ ] Update inventory file with instance IPs
- [ ] Run `ansible-playbook playbooks/common.yml`
- [ ] Run `ansible-playbook playbooks/ollama.yml`
- [ ] Run `ansible-playbook playbooks/openwebui.yml`
- [ ] Run `ansible-playbook playbooks/nginx.yml`
- [ ] Verify services are running

### **Post-Deployment**

- [ ] Test HTTPS connectivity via domain
- [ ] Verify Ollama models are loaded
- [ ] Test OpenWebUI web interface
- [ ] Verify NGINX reverse proxy is working
- [ ] Check CloudWatch Logs for errors

---

## Security Considerations

### **Network Security**

✅ **Implemented**:
- Private subnets for compute
- Security group-based network isolation
- NAT gateways for outbound traffic
- No public IP assignments
- SSL/TLS termination at ALB

### **Access Control**

✅ **Implemented**:
- IAM least privilege roles
- SSM Session Manager for shell access
- No SSH port exposure
- Service-to-service communication via security groups

### **Data Protection**

✅ **Implemented**:
- HTTPS for all external communication
- Encrypted data in transit via TLS
- Private networking for internal communication

---

## Monitoring & Observability

### **CloudWatch Integration**

- EC2 instances send logs to CloudWatch
- ALB access logs available
- Can monitor via CloudWatch Metrics

### **Future Enhancements**

- [ ] Prometheus for metrics collection
- [ ] Grafana for visualization
- [ ] Loki for log aggregation
- [ ] ELK stack for centralized logging

---

## Scaling Considerations

### **Current State**
- Single instance per service
- Suitable for development/testing

### **Future Scaling Options**
- [ ] Auto Scaling Groups for EC2
- [ ] Application Load Balancer with multiple targets
- [ ] EFS for shared model storage
- [ ] RDS for centralized state management
- [ ] ElastiCache for caching layer

---

## Disaster Recovery

### **Backup Strategy**

- [ ] Regular AMI snapshots
- [ ] Terraform state versioning
- [ ] Model storage backup to S3

### **Recovery Procedures**

- [ ] Terraform can recreate infrastructure
- [ ] Ansible can quickly redeploy services
- [ ] Models can be re-downloaded

---

## Document Map

| Document | Purpose | Audience |
|---|---|---|
| **README.md** | High-level overview | Everyone |
| **ARCHITECTURE.md** | System design & dependencies | Architects, Ops |
| **terraform/README.md** | IaC deployment guide | DevOps, Engineers |
| **ansible/README.md** | Configuration management | DevOps, Ops |
| **terraform/modules/*/README.md** | Module-specific details | Engineers |
| **ansible/roles/*/README.md** | Role-specific details | DevOps |

