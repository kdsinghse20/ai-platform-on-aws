# Getting Started - AI Platform on AWS

**Quick start guide for new team members and first-time deployers.**

---

## 👋 Welcome!

You're reading the documentation for **AI Platform on AWS** - a production-style deployment of:
- **Ollama**: Self-hosted AI model runtime
- **OpenWebUI**: Web chat interface for Ollama
- **NGINX**: Reverse proxy
- **AWS Infrastructure**: VPC, EC2, ALB, IAM, security groups

This project demonstrates infrastructure best practices using Terraform (IaC) and Ansible (configuration management).

---

## 🎯 What This Project Does

```
Users → HTTPS → ALB → NGINX → OpenWebUI → Ollama → AI Models
```

**In 5 minutes**: Users access a web interface that talks to AI models running locally.

**In production**: Fully managed AWS infrastructure, private networks, TLS encryption, health checks, auto-recovery.

---

## 📚 Documentation Path

### **For Understanding** (30 minutes)
1. This file ✓
2. [01-ARCHITECTURE.md](01-ARCHITECTURE.md) - System design

### **For Deploying** (2-3 hours)
1. [02-DEPLOYMENT_GUIDE.md](02-DEPLOYMENT_GUIDE.md) - Full walkthrough
2. [terraform/README.md](terraform/README.md) - Infrastructure
3. [ansible/README.md](ansible/README.md) - Configuration

### **For Troubleshooting** (as needed)
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Common issues

---

## 🏗️ System Overview

### **Components**

| Component | Purpose | Technology |
|-----------|---------|-----------|
| **VPC** | Network isolation | AWS VPC, subnets, security groups |
| **EC2 Instances** | Compute | Ubuntu 24.04 LTS, t3.large |
| **Ollama Instance** | AI Runtime | Ollama models (Gemma 3, Llama 3.2) |
| **OpenWebUI Instance** | Web Interface | Docker, Python |
| **NGINX** | Reverse Proxy | NGINX, SSL/TLS |
| **ALB** | Load Balancer | AWS Application Load Balancer |
| **IAM** | Permissions | AWS IAM roles, SSM access |

### **Architecture (High Level)**

```
Internet (Users)
    ↓
Route53 (DNS)
    ↓
ALB (HTTPS Termination)
    ↓
NGINX (Reverse Proxy)
    ↓
OpenWebUI (Web UI)
    ↓
Ollama (AI Runtime)
    ↓
Models (Gemma 3, Llama 3.2)
```

**Key Feature**: Everything is in private subnets. No public IPs on compute instances. Access via AWS Systems Manager.

---

## ⚡ Quick Facts

- **Deployment Time**: 30-45 minutes
- **Infrastructure Cost**: ~$256/month (minimal usage)
- **Skills Needed**: AWS, Terraform, Ansible, Linux
- **Languages**: HCL (Terraform), YAML (Ansible, Playbooks)
- **Access Method**: AWS Systems Manager (no SSH keys)

---

## 🚀 What You Can Do With This

### **For Development/Testing**
- Deploy complete AI infrastructure in minutes
- Test model changes
- Experiment with configurations
- Learn Terraform & Ansible

### **For Production**
- Deploy self-hosted LLM infrastructure
- Integrate with applications
- Run private AI models
- Full control over data

### **For Learning**
- Study infrastructure as code (Terraform)
- Learn configuration management (Ansible)
- Understand AWS best practices
- See security patterns

---

## 📋 Prerequisites

### **Before You Start**

- [ ] AWS account with admin access
- [ ] AWS CLI configured (`aws configure`)
- [ ] Terraform installed (v1.0+)
- [ ] Ansible installed (2.10+)
- [ ] Basic Linux knowledge
- [ ] ACM certificate created (for HTTPS)
- [ ] Route53 hosted zone (for DNS)

### **AWS Setup** (if not done yet)

```bash
# 1. Configure AWS credentials
aws configure

# 2. Create ACM certificate
aws acm request-certificate \
  --domain-name yourdomain.com \
  --validation-method DNS

# 3. Create Route53 hosted zone (if needed)
aws route53 create-hosted-zone \
  --name yourdomain.com \
  --caller-reference $(date +%s)

# 4. Verify setup
aws sts get-caller-identity
```

---

## 🎯 Next Steps (Choose Your Path)

### **Path 1: I want to understand the architecture** ➜ 30 minutes
```
→ Read 01-ARCHITECTURE.md
→ Look at diagrams/ folder
→ Review component diagrams
```

### **Path 2: I want to deploy this** ➜ 2-3 hours
```
→ Read 02-DEPLOYMENT_GUIDE.md
→ Follow step-by-step
→ Use checklists in terraform/ and ansible/ docs
→ Verify with troubleshooting section
```

### **Path 3: I want to modify this** ➜ 1 hour + development
```
→ Read 01-ARCHITECTURE.md (understand design)
→ Read terraform/README.md (understand IaC structure)
→ Read ansible/README.md (understand config structure)
→ Modify specific modules/roles
→ Deploy and test changes
```

### **Path 4: I want to troubleshoot** ➜ as needed
```
→ Check TROUBLESHOOTING.md first
→ Find your error in relevant module docs
→ Follow troubleshooting section
→ Check diagrams/ for architecture clarity
```

---

## 📂 Documentation Organization

```
docs/                              ← You are here
├── README.md                       # Documentation index
├── 00-GETTING_STARTED.md          # This file
├── 01-ARCHITECTURE.md             # System design
├── 02-DEPLOYMENT_GUIDE.md         # Deployment walkthrough
├── TROUBLESHOOTING.md             # Common issues
├── terraform/                     # Infrastructure docs
│   ├── README.md
│   ├── 01-VPC.md
│   ├── 02-SECURITY_GROUPS.md
│   ├── 03-IAM.md
│   ├── 04-EC2.md
│   └── 05-ALB.md
└── ansible/                       # Configuration docs
    ├── README.md
    ├── 01-COMMON_ROLE.md
    ├── 02-OLLAMA_ROLE.md
    ├── 03-OPENWEBUI_ROLE.md
    └── 04-NGINX_ROLE.md

diagrams/                          # Visual diagrams
├── README.md                       # Diagram index
├── 01-system-architecture.txt      # Full system architecture
├── 02-network-topology.txt         # Network design
├── 03-component-flow.txt           # Data flow
├── 04-deployment-sequence.txt      # Deployment steps
└── 05-security-groups.txt          # Security architecture
```

---

## 💡 Key Concepts

### **Infrastructure as Code (Terraform)**
Terraform files describe AWS infrastructure in code. Changes are version controlled and reproducible.

### **Configuration Management (Ansible)**
Ansible playbooks configure services on instances. Idempotent (safe to run multiple times).

### **Multi-Tier Architecture**
- **Public Subnets**: ALB, NAT Gateways
- **Private App Subnets**: OpenWebUI
- **Private AI Subnets**: Ollama

### **Security**
- No public IPs on compute instances
- All traffic through load balancer
- Security groups enforce access
- IAM least privilege
- TLS encryption everywhere

---

## 🎓 Learning Resources

### **In This Documentation**
- Architecture diagrams (in `diagrams/`)
- Dependency maps (in `01-ARCHITECTURE.md`)
- Step-by-step guides (in `02-DEPLOYMENT_GUIDE.md`)
- Module-specific docs (in `terraform/` and `ansible/`)
- Troubleshooting guides (in `TROUBLESHOOTING.md`)

### **External Resources**
- [Terraform Docs](https://www.terraform.io/docs)
- [AWS Documentation](https://docs.aws.amazon.com)
- [Ansible Docs](https://docs.ansible.com)
- [Ollama Docs](https://github.com/jmorganca/ollama)

---

## ❓ FAQ

### **Q: Do I need to understand Terraform to use this?**
A: Not fully, but it helps. Read the terraform/README.md for an overview.

### **Q: Can I modify the infrastructure?**
A: Yes! Each module is documented. Make changes in Terraform, apply, then run Ansible.

### **Q: What if something breaks?**
A: Check TROUBLESHOOTING.md first, then the specific module's troubleshooting section.

### **Q: Is this production-ready?**
A: Almost. Add monitoring (Prometheus/Grafana), backup strategy, and auto-scaling for production.

### **Q: How much does this cost?**
A: ~$256/month for minimal usage. Costs scale with traffic and instance size.

---

## ✅ Deployment Checklist

Before starting deployment:
- [ ] AWS credentials configured
- [ ] Terraform installed
- [ ] Ansible installed
- [ ] ACM certificate created
- [ ] Route53 hosted zone created
- [ ] S3 bucket for Terraform state (optional but recommended)

---

## 🚦 Ready to Go?

### **Choose your next step:**

| Action | Go To |
|--------|-------|
| Understand the system | [01-ARCHITECTURE.md](01-ARCHITECTURE.md) |
| Deploy it | [02-DEPLOYMENT_GUIDE.md](02-DEPLOYMENT_GUIDE.md) |
| Troubleshoot | [TROUBLESHOOTING.md](TROUBLESHOOTING.md) |
| See diagrams | Go to `../diagrams/` |
| Learn Terraform | [terraform/README.md](terraform/README.md) |
| Learn Ansible | [ansible/README.md](ansible/README.md) |

---

## 📞 Need Help?

1. **Check the docs** - Most questions are answered in the relevant documentation
2. **Search within docs** - Use Ctrl+F to find keywords
3. **Check TROUBLESHOOTING.md** - Common issues and solutions
4. **Review module-specific docs** - terraform/ and ansible/ folders
5. **Check diagrams/** - Visual reference

---

**Ready to dive in? → Read [01-ARCHITECTURE.md](01-ARCHITECTURE.md) next!**

---

**Last Updated**: August 3, 2026 | **Version**: 1.0
