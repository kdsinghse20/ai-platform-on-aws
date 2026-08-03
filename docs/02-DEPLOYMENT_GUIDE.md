# Deployment Guide - Step by Step

**Complete step-by-step guide for deploying the AI Platform.**

---

## Quick Overview

1. **Terraform** (~20 min) → Creates infrastructure
2. **Ansible** (~50 min) → Configures services
3. **Verification** (~10 min) → Tests everything

---

## Phase 1: Infrastructure Deployment (Terraform)

### Step 1: Initialize Terraform

```bash
cd terraform/environments/dev
terraform init
```

### Step 2: Review Plan

```bash
terraform plan -out=tfplan
```

Review output for:
- Correct number of resources
- Expected instance types
- Correct CIDR ranges

### Step 3: Apply Configuration

```bash
terraform apply tfplan
```

This creates:
- VPC & subnets
- Security groups
- IAM roles
- EC2 instances
- Application Load Balancer

### Step 4: Generate Ansible Inventory

```bash
terraform output -raw ansible_inventory > ../../../ansible/inventory/hosts.yml
```

**Estimated Time**: 15-20 minutes

---

## Phase 2: Service Configuration (Ansible)

### Step 1: Verify Connectivity

```bash
cd ansible
ansible all -m ping -i inventory/hosts.yml
```

Expected: All hosts respond "pong"

### Step 2: Run All Playbooks

```bash
ansible-playbook playbooks/site.yml -i inventory/hosts.yml
```

This runs:
1. **Common Role** - System setup & dependencies
2. **Ollama Role** - AI model runtime installation
3. **OpenWebUI Role** - Web interface setup
4. **NGINX Role** - Reverse proxy configuration

Or run individually:

```bash
ansible-playbook playbooks/common.yml -i inventory/hosts.yml
ansible-playbook playbooks/ollama.yml -i inventory/hosts.yml
ansible-playbook playbooks/openwebui.yml -i inventory/hosts.yml
ansible-playbook playbooks/nginx.yml -i inventory/hosts.yml
```

**Estimated Time**: 30-50 minutes

---

## Phase 3: Verification

### Test Ollama API

```bash
curl -s http://10.0.20.x:11434/api/tags | python3 -m json.tool
```

Expected: JSON listing loaded models

### Test OpenWebUI

```bash
curl -s http://10.0.10.x:8080 | head -20
```

Expected: HTML content

### Test via ALB

```bash
curl -k https://alb-dns-name
```

Expected: OpenWebUI HTML response

### Full End-to-End Test

1. Open browser
2. Navigate to `https://yourdomain.com` (or ALB DNS)
3. Type a question
4. Verify response from AI model

**Estimated Time**: 5-10 minutes

---

## Troubleshooting

If something fails:

1. **Check Terraform errors**
   - Review error message
   - Check AWS account permissions
   - See `terraform/README.md`

2. **Check Ansible errors**
   - Run with verbose: `ansible-playbook ... -vvv`
   - Check service logs
   - See `TROUBLESHOOTING.md`

3. **Check connectivity**
   - `ansible all -m ping`
   - SSH via AWS Systems Manager
   - Check security groups

---

## Pre-Deployment Checklist

- [ ] AWS credentials configured
- [ ] Terraform v1.0+ installed
- [ ] Ansible installed
- [ ] ACM certificate created
- [ ] Route53 hosted zone ready
- [ ] S3 backend bucket (optional)

---

## Post-Deployment Checklist

- [ ] All Terraform resources created
- [ ] Ansible playbooks completed
- [ ] Ollama API responding
- [ ] OpenWebUI accessible
- [ ] NGINX reverse proxy working
- [ ] Full end-to-end test passed

---

For detailed documentation on specific components:
- **Terraform**: See `terraform/README.md`
- **Ansible**: See `ansible/README.md`
- **Troubleshooting**: See `TROUBLESHOOTING.md`

---

**Last Updated**: August 3, 2026 | **Version**: 1.0
