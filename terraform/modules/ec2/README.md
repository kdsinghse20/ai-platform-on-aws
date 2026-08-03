# EC2 Module - Compute Instances

Launches and configures EC2 instances for OpenWebUI and Ollama services.

---

## Overview

Generic EC2 module used to launch two instances:
1. **OpenWebUI Instance** - Web UI + NGINX (Private App Subnet)
2. **Ollama Instance** - AI Model Runtime (Private AI Subnet)

Both instances:
- Run Ubuntu 24.04 LTS
- Include IAM instance profile for AWS permissions
- Placed in private subnets (no public IP)
- Managed via AWS Systems Manager

---

## Input Variables

| Variable | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `project_name` | string | - | ✅ Yes | Project name for resource naming |
| `environment` | string | - | ✅ Yes | Environment (dev, staging, prod) |
| `instance_name` | string | - | ✅ Yes | Instance identifier (openwebui, ollama) |
| `ami_id` | string | - | ✅ Yes | AMI ID (Ubuntu 24.04 LTS) |
| `instance_type` | string | - | ✅ Yes | Instance type (t3.large) |
| `subnet_id` | string | - | ✅ Yes | Subnet ID for placement |
| `security_group_ids` | list(string) | - | ✅ Yes | Security group IDs |
| `iam_instance_profile` | string | - | ✅ Yes | Instance profile name |
| `root_volume_size` | number | 50 | ❌ No | Root volume size in GB |
| `root_volume_type` | string | gp3 | ❌ No | EBS volume type |

---

## Output Values

| Output | Type | Description |
|--------|------|-------------|
| `instance_id` | string | EC2 instance ID |
| `instance_private_ip` | string | Private IP address |
| `instance_public_ip` | string | Public IP (if assigned) |
| `primary_eni_id` | string | Primary network interface ID |

---

## Usage Example

### **OpenWebUI Instance**

```hcl
module "openwebui" {
  source = "../../modules/ec2"

  project_name = "ai-ollama"
  environment  = "dev"
  instance_name = "openwebui"
  
  ami_id = data.aws_ami.ubuntu.id
  instance_type = "t3.large"
  
  subnet_id = module.vpc.private_app_subnet_ids[0]
  security_group_ids = [module.security_groups.openwebui_security_group_id]
  
  iam_instance_profile = module.iam.instance_profile_name
}
```

### **Ollama Instance**

```hcl
module "ollama" {
  source = "../../modules/ec2"

  project_name = "ai-ollama"
  environment  = "dev"
  instance_name = "ollama"
  
  ami_id = data.aws_ami.ubuntu.id
  instance_type = "t3.large"
  
  subnet_id = module.vpc.private_ai_subnet_ids[0]
  security_group_ids = [module.security_groups.ollama_security_group_id]
  
  iam_instance_profile = module.iam.instance_profile_name
}
```

---

## Instance Configuration

### **Ubuntu 24.04 LTS AMI**

Automatically selected in dev environment:

```hcl
data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"]  # Canonical
  
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}
```

### **OpenWebUI Instance Specs**

| Property | Value |
|----------|-------|
| Instance Type | t3.large |
| vCPUs | 2 |
| Memory | 8 GiB |
| Network Performance | Up to 5 Gigabit |
| Subnet | Private App |
| Storage | 50 GiB gp3 EBS |
| Public IP | None |
| IAM Role | SSM + CloudWatch access |

### **Ollama Instance Specs**

| Property | Value |
|----------|-------|
| Instance Type | t3.large |
| vCPUs | 2 |
| Memory | 8 GiB |
| Network Performance | Up to 5 Gigabit |
| Subnet | Private AI |
| Storage | 50 GiB gp3 EBS |
| Public IP | None |
| IAM Role | SSM + CloudWatch access |

---

## Network Configuration

### **Private Subnet Placement**

Both instances are placed in **private subnets**:
- No direct internet access
- No public IP assignment
- Outbound via NAT Gateway
- Access via AWS Systems Manager

### **Network Interfaces**

Each instance has one ENI (Elastic Network Interface):
- Attached to private subnet
- Associated with security group
- Private IP address assigned automatically
- Source/Destination Check enabled

---

## Storage Configuration

### **Root Volume**

- **Type**: gp3 (General Purpose SSD v3)
- **Size**: 50 GB (configurable)
- **Encryption**: Enabled by default
- **Delete on Termination**: Yes
- **IOPS**: Auto-optimized
- **Throughput**: Auto-optimized

### **Volume Rationale**

- **50 GB**: Sufficient for OS + runtime + logs
- **gp3**: Cost-effective, good performance
- **Encryption**: Security best practice
- **Expandable**: Can increase volume size if needed

---

## IAM Integration

### **Instance Profile**

Each instance gets an IAM instance profile:
- Allows assumption of service role
- Provides temporary credentials
- Automatically rotated

### **Permissions Provided**

Via IAM module:
- CloudWatch Logs write access
- AWS Systems Manager Session Manager access
- S3 read access (for configuration)

---

## Dependency Chain

```
EC2 Module
    ↓
Requires:
    - VPC (for subnet_id)
    - Security Groups (for security_group_ids)
    - IAM (for iam_instance_profile)
    - AMI (for ami_id)
    ↓
Used By:
    - ALB (target instances)
    - Ansible (configuration management)
```

---

## Access Methods

### **AWS Systems Manager Session Manager**

No SSH required! Access via:

```bash
# List instances
aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running"

# Start session
aws ssm start-session --target i-xxxxxxxxx

# Copy files
aws s3 cp file.txt s3://bucket/path/

# Run remote commands
aws ssm send-command \
  --instance-ids i-xxxxxxxxx \
  --document-name "AWS-RunShellScript" \
  --parameters 'commands=["docker ps"]'
```

### **CloudWatch Logs**

Monitor instance output:

```bash
# View logs
aws logs tail /aws/ec2/launch --follow

# Retrieve specific time range
aws logs get-log-events \
  --log-group-name /aws/ec2/launch \
  --log-stream-name instance-id
```

---

## Terraform Code Structure

```hcl
# Instance resource
resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  iam_instance_profile   = var.iam_instance_profile
  
  # Volume configuration
  root_block_device {
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
    delete_on_termination = true
    encrypted             = true
  }
  
  # Tags
  tags = {
    Name        = "${var.project_name}-${var.instance_name}-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}
```

---

## Common Operations

### **View Instance Details**

```bash
# List instances
aws ec2 describe-instances --instance-ids i-xxxxxxxxx

# Get private IP
aws ec2 describe-instances \
  --instance-ids i-xxxxxxxxx \
  --query 'Reservations[0].Instances[0].PrivateIpAddress'

# Check instance state
aws ec2 describe-instance-status --instance-ids i-xxxxxxxxx
```

### **Manage Instances**

```bash
# Stop instance
aws ec2 stop-instances --instance-ids i-xxxxxxxxx

# Start instance
aws ec2 start-instances --instance-ids i-xxxxxxxxx

# Reboot instance
aws ec2 reboot-instances --instance-ids i-xxxxxxxxx

# Terminate instance
aws ec2 terminate-instances --instance-ids i-xxxxxxxxx
```

### **Modify Instance**

```bash
# Change instance type (requires stop)
aws ec2 stop-instances --instance-ids i-xxxxxxxxx
aws ec2 modify-instance-attribute \
  --instance-id i-xxxxxxxxx \
  --instance-type t3.xlarge

# Expand root volume
aws ec2 modify-volume --volume-id vol-xxxxxxxxx --size 100
```

---

## Monitoring

### **CloudWatch Metrics**

Available metrics:
- CPU Utilization
- Network In/Out
- Disk Read/Write
- Status Checks

```bash
# View CPU metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --dimensions Name=InstanceId,Value=i-xxxxxxxxx \
  --start-time 2026-08-01T00:00:00Z \
  --end-time 2026-08-03T00:00:00Z \
  --period 3600 \
  --statistics Average
```

### **Status Checks**

Monitor instance health:

```bash
# Check status
aws ec2 describe-instance-status --instance-ids i-xxxxxxxxx

# Expected output:
# InstanceStatus: ok (system + instance checks pass)
# SystemStatus: ok (underlying hardware OK)
```

---

## Security

### ✅ Implemented

- [ ] Private IP only (no public assignment)
- [ ] Security groups restrict traffic
- [ ] IAM instance profile for permissions
- [ ] EBS encryption enabled
- [ ] Systems Manager access (no SSH keys)
- [ ] CloudWatch monitoring
- [ ] VPC Flow Logs for traffic analysis

### 🔒 Production Hardening

- [ ] Disable detailed monitoring when not needed
- [ ] Rotate security groups regularly
- [ ] Monitor CloudWatch Logs
- [ ] Set up CloudWatch alarms
- [ ] Regular patch management
- [ ] Enable termination protection

---

## Troubleshooting

### **Instance Won't Start**

```bash
# Check system status
aws ec2 describe-instance-status --instance-ids i-xxxxxxxxx

# Check CloudWatch logs
aws logs tail /aws/ec2/launch --follow

# Verify AMI exists
aws ec2 describe-images --image-ids ami-xxxxxxxxx

# Check subnet availability
aws ec2 describe-subnets --subnet-ids subnet-xxxxxxxxx
```

### **Can't Access via SSM**

```bash
# Verify SSM permissions
aws iam get-role --role-name ssm-role

# Check instance SSM agent status
aws ssm describe-instance-information --instance-information-filter-list "key=tag:Name,valueSet=instance-name"

# Test connection
aws ssm start-session --target i-xxxxxxxxx
```

### **High CPU Usage**

```bash
# Check processes (via SSM)
aws ssm send-command \
  --instance-ids i-xxxxxxxxx \
  --document-name AWS-RunShellScript \
  --parameters commands=["top -b -n 1 | head -20"]
```

---

## Cost Optimization

### **Instance Sizing**

Current: `t3.large` (2 vCPU, 8 GB RAM)

**When to upsize**:
- High model inference load
- Multiple concurrent requests
- GPU acceleration needed

**When to downsize**:
- Light usage pattern
- Dev/test environment
- Cost optimization priority

### **On-Demand vs Reserved**

```bash
# On-Demand pricing (current)
t3.large = ~$0.10/hour

# Reserved Instance (1-year)
t3.large = ~$0.065/hour (35% savings)

# Spot Instances (risky)
t3.large = ~$0.03/hour (70% savings)
```

---

## Best Practices

### ✅ DO
- [ ] Use private subnets for compute
- [ ] Access via Systems Manager
- [ ] Monitor CloudWatch metrics
- [ ] Encrypt EBS volumes
- [ ] Use IAM instance profiles
- [ ] Tag all instances
- [ ] Document custom AMIs
- [ ] Regular backups (AMI snapshots)

### ❌ DON'T
- [ ] Expose instances to internet
- [ ] Use SSH keys for private instances
- [ ] Disable encryption
- [ ] Skip security groups
- [ ] Forget to clean up instances
- [ ] Mix environments on same instance
- [ ] Hardcode configuration

---

## Advanced Topics

### **User Data Scripts**

For custom initialization:

```hcl
resource "aws_instance" "this" {
  # ... other config
  
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    environment = var.environment
    project     = var.project_name
  }))
}
```

### **Detailed Monitoring**

Enable for important instances:

```hcl
resource "aws_instance" "this" {
  # ... other config
  
  monitoring = true  # 1-minute metrics instead of 5-minute
}
```

### **Spot Instances**

For cost savings (interruptible):

```hcl
resource "aws_instance" "this" {
  # ... other config
  
  instance_market_options {
    market_type = "spot"
    spot_options {
      max_price = "0.05"  # Max price per hour
    }
  }
}
```

---

## Related Documentation

- [AWS EC2 Instance Types](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html)
- [Ubuntu 24.04 LTS AMI](https://cloud-images.ubuntu.com/)
- [Systems Manager Session Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html)
- [Terraform EC2 Instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)
- [Main Terraform README](../README.md)
- [Architecture Guide](../../ARCHITECTURE.md)

---

**Last Updated**: August 3, 2026 | **Version**: 1.0 | **Maintainer**: DevOps Team
