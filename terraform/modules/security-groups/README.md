# Security Groups Module - Network Access Control

Manages AWS Security Groups and firewall rules for all infrastructure components.

---

## Overview

This module defines network access control policies for:
- **ALB Security Group**: Application Load Balancer
- **OpenWebUI Security Group**: Web UI and reverse proxy server
- **Ollama Security Group**: AI model runtime server

---

## Architecture

```
┌──────────────────────────────────────────────────────┐
│           Internet (0.0.0.0/0)                       │
└────────────────────┬─────────────────────────────────┘
                     │
          ┌──────────▼──────────┐
          │   ALB Security Group │
          │                      │
          │ ✅ Inbound:          │
          │  - Port 80 (HTTP)    │
          │  - Port 443 (HTTPS)  │
          │  From: 0.0.0.0/0     │
          │                      │
          │ ✅ Outbound:         │
          │  - Port 80 to        │
          │    OpenWebUI SG      │
          └──────────┬───────────┘
                     │
          ┌──────────▼──────────────────┐
          │ OpenWebUI Security Group     │
          │                              │
          │ ✅ Inbound:                  │
          │  - Port 80 from ALB SG      │
          │  - Port 22 from SSM         │
          │                              │
          │ ✅ Outbound:                 │
          │  - Port 11434 to Ollama SG  │
          │  - Port 443 to 0.0.0.0/0    │
          └──────────┬───────────────────┘
                     │
          ┌──────────▼──────────────────┐
          │  Ollama Security Group       │
          │                              │
          │ ✅ Inbound:                  │
          │  - Port 11434 from          │
          │    OpenWebUI SG             │
          │  - Port 22 from SSM         │
          │                              │
          │ ✅ Outbound:                 │
          │  - Port 443 to 0.0.0.0/0    │
          │    (model downloads)        │
          └─────────────────────────────┘
```

---

## Input Variables

| Variable | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `vpc_id` | string | - | ✅ Yes | VPC ID for security groups |

---

## Output Values

| Output | Type | Description |
|--------|------|-------------|
| `alb_security_group_id` | string | ALB security group ID |
| `openwebui_security_group_id` | string | OpenWebUI security group ID |
| `ollama_security_group_id` | string | Ollama security group ID |

---

## Security Group Details

### **1. ALB Security Group**

**Purpose**: Manages inbound/outbound traffic for Application Load Balancer

**Inbound Rules**:

| Protocol | Port | Source | Purpose |
|----------|------|--------|---------|
| TCP | 80 | 0.0.0.0/0 | HTTP from internet |
| TCP | 443 | 0.0.0.0/0 | HTTPS from internet |

**Outbound Rules**:

| Protocol | Port | Destination | Purpose |
|----------|------|-------------|---------|
| TCP | 80 | OpenWebUI SG | Forward to OpenWebUI |

**Additional Notes**:
- Ingress from entire internet (0.0.0.0/0) as expected for public load balancer
- Only forwards HTTP traffic to OpenWebUI
- HTTPS terminated at ALB (TLS/SSL offloading)

---

### **2. OpenWebUI Security Group**

**Purpose**: Controls access to OpenWebUI application server

**Inbound Rules**:

| Protocol | Port | Source | Purpose |
|----------|------|--------|---------|
| TCP | 80 | ALB SG | HTTP from load balancer |
| TCP | 22 | AWS Systems Manager | SSM Session Manager access |

**Outbound Rules**:

| Protocol | Port | Destination | Purpose |
|----------|------|-------------|---------|
| TCP | 11434 | Ollama SG | Ollama API requests |
| TCP | 443 | 0.0.0.0/0 | HTTPS for external APIs |

**Additional Notes**:
- Port 80 only accessible from ALB (via security group rule)
- No SSH exposure (uses AWS Systems Manager)
- Can reach Ollama on port 11434
- Can reach external HTTPS endpoints (model registries, updates)

---

### **3. Ollama Security Group**

**Purpose**: Controls access to Ollama AI runtime

**Inbound Rules**:

| Protocol | Port | Source | Purpose |
|----------|------|--------|---------|
| TCP | 11434 | OpenWebUI SG | Ollama API from OpenWebUI |
| TCP | 22 | AWS Systems Manager | SSM Session Manager access |

**Outbound Rules**:

| Protocol | Port | Destination | Purpose |
|----------|------|-------------|---------|
| TCP | 443 | 0.0.0.0/0 | HTTPS for model downloads |

**Additional Notes**:
- Port 11434 only accessible from OpenWebUI SG
- No SSH exposure (uses AWS Systems Manager)
- Can download models via HTTPS
- Cannot be reached from internet directly

---

## Dependency Chain

```
Security Groups Module
        ↓
    Requires: VPC (vpc_id)
        ↓
    Used By:
    - EC2 Module (for instance launch)
    - ALB Module (for load balancer)
```

---

## Usage Example

```hcl
module "security_groups" {
  source = "../../modules/security-groups"
  
  vpc_id = module.vpc.vpc_id
}

# Use in EC2 module
resource "aws_instance" "openwebui" {
  security_groups = [module.security_groups.openwebui_security_group_id]
}
```

---

## Security Analysis

### **Network Isolation**

✅ **Implemented**:
- Public ALB only accessible from internet
- Private instances only accessible via security group rules
- No cross-service access beyond necessary ports
- AI model runtime isolated from web traffic

### **Access Control**

✅ **Implemented**:
- No SSH on port 22 (uses Systems Manager)
- Principle of least privilege
- Explicit allow rules (no deny rules needed)
- Service-to-service via security group references

### **External Communication**

✅ **Controlled**:
- OpenWebUI → Ollama on port 11434 only
- Ollama → Internet on port 443 only (for model downloads)
- ALB → Internet on ports 80/443 only

---

## Terraform Code Structure

```hcl
# VPC-bound security groups
resource "aws_security_group" "alb"
resource "aws_security_group" "openwebui"
resource "aws_security_group" "ollama"

# ALB inbound rules
resource "aws_vpc_security_group_ingress_rule" "alb_http"
resource "aws_vpc_security_group_ingress_rule" "alb_https"

# ALB outbound rule
resource "aws_vpc_security_group_egress_rule" "alb_to_openwebui"

# OpenWebUI inbound rules
resource "aws_vpc_security_group_ingress_rule" "openwebui_from_alb"
resource "aws_vpc_security_group_ingress_rule" "openwebui_from_ssm"

# OpenWebUI outbound rules
resource "aws_vpc_security_group_egress_rule" "openwebui_to_ollama"
resource "aws_vpc_security_group_egress_rule" "openwebui_to_internet"

# Ollama inbound rules
resource "aws_vpc_security_group_ingress_rule" "ollama_from_openwebui"
resource "aws_vpc_security_group_ingress_rule" "ollama_from_ssm"

# Ollama outbound rule
resource "aws_vpc_security_group_egress_rule" "ollama_to_internet"
```

---

## Common Operations

### **View Security Group Rules**

```bash
# List all rules
aws ec2 describe-security-groups --group-ids sg-xxxxxxxxx

# Show inbound rules only
aws ec2 describe-security-group-rules \
  --filters Name=group-id,Values=sg-xxxxxxxxx Name=is-egress,Values=false

# Show outbound rules only
aws ec2 describe-security-group-rules \
  --filters Name=group-id,Values=sg-xxxxxxxxx Name=is-egress,Values=true
```

### **Modify Rules**

```bash
# Add inbound rule
aws ec2 authorize-security-group-ingress \
  --group-id sg-xxxxxxxxx \
  --protocol tcp \
  --port 3306 \
  --cidr 10.0.0.0/16

# Remove inbound rule
aws ec2 revoke-security-group-ingress \
  --group-id sg-xxxxxxxxx \
  --protocol tcp \
  --port 3306 \
  --cidr 10.0.0.0/16
```

---

## Port Reference

### **Used Ports**

| Port | Protocol | Service | Flow |
|------|----------|---------|------|
| 80 | TCP | HTTP | Internet → ALB → OpenWebUI |
| 443 | TCP | HTTPS | Internet → ALB (TLS termination) |
| 8080 | TCP | OpenWebUI | ALB → OpenWebUI (internal) |
| 11434 | TCP | Ollama API | OpenWebUI → Ollama |
| 22 | TCP | SSH | AWS Systems Manager |

---

## Troubleshooting

### **Can't Connect to OpenWebUI**

```bash
# 1. Verify ALB SG allows port 80
aws ec2 describe-security-groups --group-ids sg-alb | grep -A5 "IpPermissions"

# 2. Check OpenWebUI SG allows ALB
aws ec2 describe-security-groups --group-ids sg-openwebui | grep -A5 "IpPermissions"

# 3. Verify ALB routes to OpenWebUI
aws elbv2 describe-target-health --target-group-arn arn:aws:elasticloadbalancing:...
```

### **Can't Connect to Ollama**

```bash
# 1. Verify Ollama SG allows OpenWebUI
aws ec2 describe-security-groups --group-ids sg-ollama

# 2. Check OpenWebUI SG allows Ollama
aws ec2 describe-security-groups --group-ids sg-openwebui

# 3. Test connectivity
ssh -i key.pem ubuntu@10.0.10.x
curl http://10.0.20.x:11434/api/tags
```

### **Can't Access Instance via SSM**

```bash
# 1. Verify SSM access rule exists
aws ec2 describe-security-groups --group-ids sg-openwebui | grep 22

# 2. Check IAM instance profile has SSM permissions
aws iam get-role --role-name <role-name>

# 3. Test SSM access
aws ssm start-session --target i-xxxxxxxxx
```

---

## Best Practices

### ✅ DO
- [ ] Use security group references for inter-service rules
- [ ] Document port usage and purposes
- [ ] Review rules periodically
- [ ] Test connectivity after changes
- [ ] Use least privilege principle
- [ ] Restrict outbound when possible
- [ ] Monitor security group changes

### ❌ DON'T
- [ ] Allow 0.0.0.0/0 for private services
- [ ] Open unnecessary ports
- [ ] Use overly broad CIDR ranges
- [ ] Ignore outbound rules
- [ ] Keep unused rules
- [ ] Change rules without testing

---

## Advanced Topics

### **Conditional Rules**

For GPU instances needing different ports:

```hcl
# Only add GPU port if GPU enabled
resource "aws_vpc_security_group_ingress_rule" "ollama_gpu" {
  count = var.enable_gpu ? 1 : 0
  
  group_id = aws_security_group.ollama.id
  
  from_port   = 5000
  to_port     = 5000
  ip_protocol = "tcp"
  referenced_security_group_id = aws_security_group.ollama.id
}
```

### **Dynamic Rules**

For multiple service connections:

```hcl
locals {
  inbound_rules = {
    http = { from_port = 80, to_port = 80 }
    https = { from_port = 443, to_port = 443 }
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb" {
  for_each = local.inbound_rules
  
  group_id = aws_security_group.alb.id
  
  from_port   = each.value.from_port
  to_port     = each.value.to_port
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"
}
```

---

## Monitoring

### **CloudTrail Logging**

Monitor security group changes:

```bash
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=ResourceName,AttributeValue=sg-xxxxxxxxx
```

### **VPC Flow Logs**

Capture network traffic:

```hcl
resource "aws_flow_log" "security_group" {
  iam_role_arn    = aws_iam_role.vpc_flow_logs.arn
  log_destination = aws_cloudwatch_log_group.vpc.arn
  traffic_type    = "ALL"
  vpc_id          = var.vpc_id
}
```

---

## Related Documentation

- [AWS Security Groups Documentation](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html)
- [Security Group Rules Documentation](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html#VPCSecurityGroupRules)
- [Terraform AWS Security Group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)
- [Main Terraform README](../README.md)
- [Architecture Guide](../../ARCHITECTURE.md)

---

**Last Updated**: August 3, 2026 | **Version**: 1.0 | **Maintainer**: DevOps Team
