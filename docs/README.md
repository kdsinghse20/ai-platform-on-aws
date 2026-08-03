# Documentation - AI Platform on AWS

Complete documentation repository for the AI Platform infrastructure project.

---

## 📚 Documentation Structure

```
docs/
├── README.md                        # This file - documentation index
├── 00-GETTING_STARTED.md           # Quick start guide
├── 01-ARCHITECTURE.md              # System design & dependencies
├── 02-DEPLOYMENT_GUIDE.md          # Step-by-step deployment
│
├── terraform/                      # Infrastructure as Code
│   ├── README.md                   # Terraform overview
│   ├── 01-VPC.md                   # VPC & networking module
│   ├── 02-SECURITY_GROUPS.md       # Security groups & firewall
│   ├── 03-IAM.md                   # Identity & permissions
│   ├── 04-EC2.md                   # Compute instances
│   ├── 05-ALB.md                   # Load balancer
│   └── DEPLOYMENT_CHECKLIST.md     # Pre-deployment checklist
│
├── ansible/                        # Configuration Management
│   ├── README.md                   # Ansible overview
│   ├── 01-COMMON_ROLE.md           # System setup
│   ├── 02-OLLAMA_ROLE.md           # AI runtime
│   ├── 03-OPENWEBUI_ROLE.md        # Web interface
│   ├── 04-NGINX_ROLE.md            # Reverse proxy
│   └── DEPLOYMENT_CHECKLIST.md     # Pre-deployment checklist
│
└── TROUBLESHOOTING.md              # Common issues & solutions
```

---

## 🎯 Quick Navigation

### **I want to...**

- **Understand the project** → Start with [00-GETTING_STARTED.md](00-GETTING_STARTED.md)
- **See system design** → Read [01-ARCHITECTURE.md](01-ARCHITECTURE.md)
- **Deploy infrastructure** → Follow [terraform/README.md](terraform/README.md)
- **Configure services** → Follow [ansible/README.md](ansible/README.md)
- **Find a specific topic** → Use table below

### **By Role**

| Role | Start Here | Then Read |
|------|-----------|-----------|
| **New Engineer** | [00-GETTING_STARTED.md](00-GETTING_STARTED.md) | [01-ARCHITECTURE.md](01-ARCHITECTURE.md) |
| **DevOps Engineer** | [01-ARCHITECTURE.md](01-ARCHITECTURE.md) | [terraform/README.md](terraform/README.md) |
| **SRE/Operations** | [02-DEPLOYMENT_GUIDE.md](02-DEPLOYMENT_GUIDE.md) | [TROUBLESHOOTING.md](TROUBLESHOOTING.md) |
| **Security Engineer** | [01-ARCHITECTURE.md](01-ARCHITECTURE.md) | [terraform/02-SECURITY_GROUPS.md](terraform/02-SECURITY_GROUPS.md) |

---

## 📄 Documentation Index

### **High-Level Documentation**

| Document | Purpose | Audience |
|----------|---------|----------|
| [00-GETTING_STARTED.md](00-GETTING_STARTED.md) | Quick start guide | Everyone |
| [01-ARCHITECTURE.md](01-ARCHITECTURE.md) | System design, dependencies, data flow | Architects, DevOps |
| [02-DEPLOYMENT_GUIDE.md](02-DEPLOYMENT_GUIDE.md) | Complete deployment walkthrough | DevOps Engineers |
| [TROUBLESHOOTING.md](TROUBLESHOOTING.md) | Common issues and solutions | Operations, Support |

### **Infrastructure Documentation (Terraform)**

| Document | Topic | Audience |
|----------|-------|----------|
| [terraform/README.md](terraform/README.md) | IaC overview & deployment guide | DevOps Engineers |
| [terraform/01-VPC.md](terraform/01-VPC.md) | VPC, subnets, networking | Cloud Architects |
| [terraform/02-SECURITY_GROUPS.md](terraform/02-SECURITY_GROUPS.md) | Firewall rules, access control | Security Engineers |
| [terraform/03-IAM.md](terraform/03-IAM.md) | IAM roles, policies, permissions | Security Engineers |
| [terraform/04-EC2.md](terraform/04-EC2.md) | EC2 instances, monitoring | DevOps Engineers |
| [terraform/05-ALB.md](terraform/05-ALB.md) | Load balancer, HTTPS, health checks | DevOps Engineers |

### **Configuration Documentation (Ansible)**

| Document | Topic | Audience |
|----------|-------|----------|
| [ansible/README.md](ansible/README.md) | Ansible overview & deployment guide | DevOps Engineers |
| [ansible/01-COMMON_ROLE.md](ansible/01-COMMON_ROLE.md) | System setup & dependencies | System Admins |
| [ansible/02-OLLAMA_ROLE.md](ansible/02-OLLAMA_ROLE.md) | Ollama installation & configuration | ML Engineers |
| [ansible/03-OPENWEBUI_ROLE.md](ansible/03-OPENWEBUI_ROLE.md) | OpenWebUI setup & integration | Full-Stack Engineers |
| [ansible/04-NGINX_ROLE.md](ansible/04-NGINX_ROLE.md) | NGINX reverse proxy | DevOps Engineers |

---

## 📊 Technology Stack

- **Cloud**: AWS (VPC, EC2, ALB, IAM, Route53, ACM)
- **IaC**: Terraform
- **Configuration**: Ansible
- **AI Runtime**: Ollama
- **Web UI**: OpenWebUI
- **Reverse Proxy**: NGINX
- **OS**: Ubuntu 24.04 LTS
- **Access**: AWS Systems Manager (SSM)

---

## 🔗 Cross-References

See [../DOCUMENTATION_INDEX.md](../DOCUMENTATION_INDEX.md) for complete cross-reference guide.

---

## 📈 Document Versions

| Document | Version | Updated |
|----------|---------|---------|
| 00-GETTING_STARTED.md | 1.0 | Aug 3, 2026 |
| 01-ARCHITECTURE.md | 1.0 | Aug 3, 2026 |
| 02-DEPLOYMENT_GUIDE.md | 1.0 | Aug 3, 2026 |
| terraform/* | 1.0 | Aug 3, 2026 |
| ansible/* | 1.0 | Aug 3, 2026 |
| TROUBLESHOOTING.md | 1.0 | Aug 3, 2026 |

---

## 🚀 Getting Started Path

1. **5 minutes**: Read [00-GETTING_STARTED.md](00-GETTING_STARTED.md)
2. **30 minutes**: Read [01-ARCHITECTURE.md](01-ARCHITECTURE.md)
3. **1 hour**: Read [terraform/README.md](terraform/README.md) OR [ansible/README.md](ansible/README.md)
4. **2+ hours**: Deep dive into specific modules

---

## 💡 Pro Tips

- Use Ctrl+F to search within documents
- Follow the numbered documents (00, 01, 02) in order
- Each document links to related topics
- Check diagrams/ folder for visual architecture

---

**Last Updated**: August 3, 2026 | **Version**: 1.0 | **Maintainer**: DevOps Team
