# VPC Module - Network Infrastructure

Manages AWS VPC and network infrastructure including subnets, internet gateway, NAT gateways, and routing.

---

## Overview

This module creates a complete Virtual Private Cloud (VPC) with multi-tier subnet architecture suitable for AI Platform deployment:

- **Public Subnets**: Internet-facing (ALB, NAT Gateways)
- **Private App Subnets**: Application layer (OpenWebUI)
- **Private AI Subnets**: AI runtime layer (Ollama)

---

## Architecture

```
┌─────────────────────────────────────────────────────┐
│             VPC (10.0.0.0/16)                       │
├─────────────────────────────────────────────────────┤
│                                                       │
│ ┌─────────────────────────────────────────────────┐ │
│ │  PUBLIC SUBNETS (IGW attached)                   │ │
│ │  10.0.1.0/24 (AZ-a) | 10.0.2.0/24 (AZ-b)       │ │
│ │                                                  │ │
│ │  Resources:                                      │ │
│ │  - Internet Gateway                             │ │
│ │  - NAT Gateway #1 (with EIP)                    │ │
│ │  - NAT Gateway #2 (with EIP)                    │ │
│ └─────────────────────────────────────────────────┘ │
│                      ▼                               │
│ ┌─────────────────────────────────────────────────┐ │
│ │  PRIVATE APP SUBNETS (NAT routed)               │ │
│ │  10.0.10.0/24 (AZ-a) | 10.0.11.0/24 (AZ-b)    │ │
│ │                                                  │ │
│ │  Resources:                                      │ │
│ │  - OpenWebUI EC2 Instance                       │ │
│ └─────────────────────────────────────────────────┘ │
│                      ▼                               │
│ ┌─────────────────────────────────────────────────┐ │
│ │  PRIVATE AI SUBNETS (NAT routed)                │ │
│ │  10.0.20.0/24 (AZ-a) | 10.0.21.0/24 (AZ-b)    │ │
│ │                                                  │ │
│ │  Resources:                                      │ │
│ │  - Ollama EC2 Instance                          │ │
│ └─────────────────────────────────────────────────┘ │
│                                                       │
└─────────────────────────────────────────────────────┘
```

---

## Input Variables

| Variable | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `vpc_name` | string | - | ✅ Yes | Name tag for VPC |
| `vpc_cidr` | string | - | ✅ Yes | CIDR block (e.g., "10.0.0.0/16") |
| `public_subnet_cidrs` | list(string) | - | ✅ Yes | Public subnet CIDR ranges |
| `private_app_subnet_cidrs` | list(string) | - | ✅ Yes | Private app subnet ranges |
| `private_ai_subnet_cidrs` | list(string) | - | ✅ Yes | Private AI subnet ranges |

---

## Output Values

| Output | Type | Description |
|--------|------|-------------|
| `vpc_id` | string | VPC ID |
| `vpc_cidr_block` | string | VPC CIDR block |
| `public_subnet_ids` | list(string) | Public subnet IDs |
| `private_app_subnet_ids` | list(string) | Private app subnet IDs |
| `private_ai_subnet_ids` | list(string) | Private AI subnet IDs |
| `internet_gateway_id` | string | IGW ID |
| `nat_gateway_ids` | list(string) | NAT Gateway IDs |
| `nat_gateway_eips` | list(string) | Elastic IP addresses |
| `public_route_table_id` | string | Public route table ID |
| `private_route_table_ids` | list(string) | Private route table IDs |

---

## Resource Details

### **VPC**
- CIDR Block: User-defined (typically 10.0.0.0/16)
- DNS hostnames enabled
- DNS support enabled

### **Subnets** (6 total)

#### **Public Subnets** (2)
- CIDR: User-defined (e.g., 10.0.1.0/24, 10.0.2.0/24)
- Availability Zones: Distributed across 2 AZs
- Auto-assign public IP: ✅ Enabled
- Route: All traffic → Internet Gateway
- Purpose: ALB, NAT Gateways

#### **Private App Subnets** (2)
- CIDR: User-defined (e.g., 10.0.10.0/24, 10.0.11.0/24)
- Availability Zones: Distributed across 2 AZs
- Auto-assign public IP: ❌ Disabled
- Route: All traffic → NAT Gateway
- Purpose: OpenWebUI EC2 instances

#### **Private AI Subnets** (2)
- CIDR: User-defined (e.g., 10.0.20.0/24, 10.0.21.0/24)
- Availability Zones: Distributed across 2 AZs
- Auto-assign public IP: ❌ Disabled
- Route: All traffic → NAT Gateway
- Purpose: Ollama EC2 instances

### **Internet Gateway**
- Provides internet access to public subnets
- Route: 0.0.0.0/0 → IGW

### **NAT Gateways** (2)
- Location: One per public subnet
- Elastic IPs: Automatically allocated
- Purpose: Outbound internet for private subnets
- Redundancy: Multi-AZ (each AZ has one)

### **Route Tables** (3)

#### **Public Route Table** (1)
- Associated with: Public subnets
- Route: 0.0.0.0/0 → IGW

#### **Private Route Tables** (2, one per AZ)
- Associated with: Private app & AI subnets
- Route: 0.0.0.0/0 → NAT Gateway (in same AZ)
- Ensures traffic stays within AZ for resilience

---

## Usage Example

### **Basic Usage**

```hcl
module "vpc" {
  source = "../../modules/vpc"

  vpc_name = "ai-ollama"
  vpc_cidr = "10.0.0.0/16"

  public_subnet_cidrs = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  private_app_subnet_cidrs = [
    "10.0.10.0/24",
    "10.0.11.0/24"
  ]

  private_ai_subnet_cidrs = [
    "10.0.20.0/24",
    "10.0.21.0/24"
  ]
}
```

### **Accessing Outputs**

```hcl
# VPC ID
resource "aws_security_group" "example" {
  vpc_id = module.vpc.vpc_id
}

# Subnet IDs
resource "aws_instance" "openwebui" {
  subnet_id = module.vpc.private_app_subnet_ids[0]
}
```

---

## CIDR Planning

### **Default Allocation** (from dev environment)

```
VPC CIDR:           10.0.0.0/16 (65,536 hosts)
├─ Public:          10.0.1.0/24 - 10.0.2.0/24    (256 hosts each)
├─ Private App:     10.0.10.0/24 - 10.0.11.0/24  (256 hosts each)
└─ Private AI:      10.0.20.0/24 - 10.0.21.0/24  (256 hosts each)

Available for future:
├─ 10.0.3.0/24 - 10.0.9.0/24   (7 subnets reserved)
├─ 10.0.12.0/24 - 10.0.19.0/24 (8 subnets reserved)
└─ 10.0.22.0/24 - 10.0.255.0/24 (234 subnets available)
```

### **Custom CIDR Planning**

For different requirements:

```hcl
# Larger VPC with more subnets
vpc_cidr = "10.0.0.0/8"  # 16M hosts

# Smaller VPC (fewer resources)
vpc_cidr = "10.0.0.0/24"  # 254 hosts only
```

---

## High Availability Features

### **Multi-AZ Deployment**
- Subnets distributed across 2+ availability zones
- Ensures services survive AZ failures
- Automatic AZ selection via `data.aws_availability_zones`

### **NAT Gateway Redundancy**
- One NAT Gateway per AZ
- Private subnets route to NAT in same AZ
- Survives single AZ failure

### **Network Segmentation**
- Public subnets isolated from private
- Private App and AI subnets separate
- Enhanced security via layering

---

## Integration with Other Modules

### **Dependencies** ← None (base infrastructure)

### **Used By** →
- Security Groups Module (needs vpc_id)
- EC2 Module (needs subnet_ids)
- ALB Module (needs vpc_id, subnet_ids)

---

## Terraform Code Structure

### **main.tf** - Resources

```hcl
# VPC creation
resource "aws_vpc" "this"

# Internet Gateway
resource "aws_internet_gateway" "this"

# Subnets (3 types, 2 each)
resource "aws_subnet" "public"
resource "aws_subnet" "private_app"
resource "aws_subnet" "private_ai"

# NAT Gateways and Elastic IPs
resource "aws_eip" "nat"
resource "aws_nat_gateway" "this"

# Route Tables
resource "aws_route_table" "public"
resource "aws_route_table" "private"

# Route Table Associations
resource "aws_route_table_association" "public"
resource "aws_route_table_association" "private_app"
resource "aws_route_table_association" "private_ai"
```

### **variables.tf** - Input Variables

```hcl
variable "vpc_name"
variable "vpc_cidr"
variable "public_subnet_cidrs"
variable "private_app_subnet_cidrs"
variable "private_ai_subnet_cidrs"
```

### **outputs.tf** - Output Values

```hcl
output "vpc_id"
output "public_subnet_ids"
output "private_app_subnet_ids"
output "private_ai_subnet_ids"
output "nat_gateway_ids"
# ... more outputs
```

---

## Networking Details

### **Routing Logic**

```
Public Subnet Traffic:
  Destination         Nexthop
  ───────────────────────────
  10.0.0.0/16        Local (VPC)
  0.0.0.0/0          Internet Gateway
  
Private Subnet Traffic:
  Destination         Nexthop
  ───────────────────────────
  10.0.0.0/16        Local (VPC)
  0.0.0.0/0          NAT Gateway (in same AZ)
```

### **Data Flow Examples**

#### **User to ALB (via public subnet)**
```
User (external) → IGW → Public Subnet → ALB
Response: ALB → IGW → User
```

#### **OpenWebUI to Ollama (private)**
```
OpenWebUI (10.0.10.x) → Private App Subnet (local)
                    → Ollama (10.0.20.x) → Private AI Subnet (local)
Response: Ollama → OpenWebUI (direct internal routing)
```

#### **OpenWebUI to Internet (model downloads)**
```
OpenWebUI (10.0.10.x) → NAT Gateway → IGW → Internet
Response: Internet → IGW → NAT Gateway → OpenWebUI
```

---

## Troubleshooting

### **Subnets Not Routing Correctly**

```bash
# Check subnet route tables
aws ec2 describe-route-tables --filters Name=vpc-id,Values=vpc-xxxxxx

# Verify routes
aws ec2 describe-route-tables --route-table-ids rtb-xxxxxx

# Check association
aws ec2 describe-route-table-associations --filters Name=subnet-id,Values=subnet-xxxxx
```

### **NAT Gateway Not Working**

```bash
# Verify NAT Gateway status
aws ec2 describe-nat-gateways --filter Name=vpc-id,Values=vpc-xxxxxx

# Check EIP allocation
aws ec2 describe-addresses --filter Name=association-id,Values=nat-xxxxxxx

# Test from instance
curl -s https://checkip.amazonaws.com  # Should show NAT Gateway IP
```

### **Instance Can't Reach Internet**

```bash
# Check instance route table
aws ec2 describe-route-tables \
  --filters Name=association.subnet-id,Values=subnet-xxxxx

# Verify NAT Gateway is running
aws ec2 describe-nat-gateways --filter Name=state,Values=available

# Check Security Group outbound rules
aws ec2 describe-security-groups --group-ids sg-xxxxx
```

---

## Best Practices

### ✅ DO
- [ ] Use consistent CIDR ranges
- [ ] Plan for growth (don't use all IPs)
- [ ] Distribute subnets across AZs
- [ ] Document subnet purposes
- [ ] Use meaningful naming conventions
- [ ] Monitor NAT Gateway traffic
- [ ] Enable VPC Flow Logs for debugging

### ❌ DON'T
- [ ] Use overlapping CIDR ranges
- [ ] Place all resources in one AZ
- [ ] Forget to attach IGW to public subnets
- [ ] Create single NAT Gateway (single point of failure)
- [ ] Make subnets too small

---

## Advanced Topics

### **VPC Peering**

To connect to another VPC:

```hcl
resource "aws_vpc_peering_connection" "example" {
  vpc_id      = module.vpc.vpc_id
  peer_vpc_id = "vpc-xxxxxxx"
  
  tags = {
    Name = "vpc-peering"
  }
}
```

### **VPN Gateway**

For hybrid connectivity:

```hcl
resource "aws_vpn_gateway" "example" {
  vpc_id = module.vpc.vpc_id
}
```

### **VPC Endpoints**

For private access to AWS services:

```hcl
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.us-east-1.s3"
  route_table_ids   = module.vpc.private_route_table_ids
}
```

---

## Monitoring

### **VPC Flow Logs**

Enable to monitor traffic:

```hcl
resource "aws_flow_log" "vpc" {
  iam_role_arn    = aws_iam_role.flow_logs_role.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs.arn
  traffic_type    = "ALL"
  vpc_id          = module.vpc.vpc_id
}
```

### **CloudWatch Metrics**

Monitor NAT Gateway:
- BytesInFromDest
- BytesOutToDestination
- ConnectionCount
- ErrorPortAllocation

---

## Cost Optimization

### **NAT Gateway Costs**
- Fixed hourly charge ($32/month per gateway)
- Bandwidth charges ($0.045/GB)
- Consider NAT Instance for low traffic

### **EIP Costs**
- Free while associated with running instance
- $3.50/month if not associated

### **Recommendations**
- [ ] Monitor NAT Gateway traffic
- [ ] Consolidate outbound traffic if possible
- [ ] Use VPC endpoints for AWS service access
- [ ] Consider using NAT instances for dev/test

---

## Related Documentation

- [Terraform AWS VPC Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc)
- [AWS VPC Best Practices](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-best-practices.html)
- [Main Terraform README](../README.md)
- [Architecture Guide](../../ARCHITECTURE.md)

---

**Last Updated**: August 3, 2026 | **Version**: 1.0 | **Maintainer**: DevOps Team
