# IAM Module - Identity & Access Management

Manages IAM roles, policies, and instance profiles for EC2 instances.

---

## Overview

This module creates:
- **EC2 Service Role**: Allows EC2 to assume permissions
- **Instance Profile**: Links role to EC2 instances
- **Policies**: CloudWatch Logs, Systems Manager, S3 access

---

## Input Variables

| Variable | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `project_name` | string | - | ✅ Yes | Project identifier |
| `environment` | string | - | ✅ Yes | Environment (dev, staging, prod) |

---

## Output Values

| Output | Type | Description |
|--------|------|-------------|
| `instance_profile_name` | string | Instance profile name (attach to EC2) |
| `instance_profile_arn` | string | Instance profile ARN |
| `role_arn` | string | IAM role ARN |
| `role_name` | string | IAM role name |

---

## Permissions Granted

### **CloudWatch Logs**

```json
{
  "Effect": "Allow",
  "Action": [
    "logs:CreateLogGroup",
    "logs:CreateLogStream",
    "logs:PutLogEvents",
    "logs:DescribeLogStreams"
  ],
  "Resource": "arn:aws:logs:*:*:*"
}
```

**Use Case**: Instances send logs to CloudWatch

### **Systems Manager Session Manager**

```json
{
  "Effect": "Allow",
  "Action": [
    "ssm:UpdateInstanceInformation",
    "ssmmessages:AcknowledgeMessage",
    "ssmmessages:GetEndpoint",
    "ssmmessages:GetMessages",
    "ec2messages:AcknowledgeMessage",
    "ec2messages:GetEndpoint",
    "ec2messages:GetMessages"
  ],
  "Resource": "*"
}
```

**Use Case**: SSH-less access via Systems Manager

### **S3 Read Access** (Optional)

```json
{
  "Effect": "Allow",
  "Action": [
    "s3:GetObject",
    "s3:GetObjectVersion"
  ],
  "Resource": "arn:aws:s3:::bucket-name/*"
}
```

**Use Case**: Download configurations, models from S3

---

## Trust Policy

Allows EC2 service to assume the role:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

---

## Usage Example

```hcl
module "iam" {
  source = "../../modules/iam"
  
  project_name = "ai-ollama"
  environment  = "dev"
}

# Attach to EC2 instance
module "openwebui" {
  source = "../../modules/ec2"
  
  iam_instance_profile = module.iam.instance_profile_name
  # ... other config
}
```

---

## Terraform Code Structure

```hcl
# IAM Role
resource "aws_iam_role" "ec2_role"

# Trust policy
data "aws_iam_policy_document" "ec2_assume_role"

# CloudWatch policy
data "aws_iam_policy_document" "cloudwatch_logs"
resource "aws_iam_role_policy" "cloudwatch"

# Systems Manager policy
data "aws_iam_policy_document" "ssm"
resource "aws_iam_role_policy" "ssm"

# Instance profile
resource "aws_iam_instance_profile" "ec2"
resource "aws_iam_role_instance_profile_attachment" "profile"
```

---

## Security Features

### ✅ Implemented

- [ ] Least privilege (minimal permissions)
- [ ] Service-specific role (not global)
- [ ] No hardcoded credentials
- [ ] Automatic credential rotation (STS)
- [ ] CloudTrail logging of access
- [ ] Trust policy restricted to EC2 service

### 🔒 Best Practices

- [ ] Regularly audit permissions
- [ ] Remove unused policies
- [ ] Use resource-specific ARNs
- [ ] Monitor IAM CloudTrail logs
- [ ] Tag resources for tracking

---

## Common Operations

```bash
# Show role details
aws iam get-role --role-name ai-ollama-dev-ec2-role

# List attached policies
aws iam list-role-policies --role-name ai-ollama-dev-ec2-role

# View inline policy
aws iam get-role-policy \
  --role-name ai-ollama-dev-ec2-role \
  --policy-name cloudwatch-logs

# Test assumed credentials
aws sts assume-role \
  --role-arn arn:aws:iam::ACCOUNT:role/ai-ollama-dev-ec2-role \
  --role-session-name test-session
```

---

## Troubleshooting

### **Permissions Denied Error**

```bash
# Check attached policies
aws iam list-role-policies --role-name role-name

# Check instance profile
aws ec2 describe-instances --instance-ids i-xxx \
  --query 'Reservations[0].Instances[0].IamInstanceProfile'

# Verify role trust
aws iam get-role --role-name role-name
```

### **Systems Manager Not Working**

```bash
# Verify SSM policy exists
aws iam get-role-policy --role-name role-name --policy-name ssm

# Check instance SSM agent
aws ssm describe-instance-information \
  --filters "Key=tag:Name,Values=instance-name"
```

---

## Cost Impact

- IAM roles: **Free**
- Instance profiles: **Free**
- Policies: **Free**

No additional cost for using IAM.

---

## Best Practices

### ✅ DO
- [ ] Use separate roles per service type
- [ ] Apply least privilege principle
- [ ] Review permissions quarterly
- [ ] Document role purposes
- [ ] Use resource-specific ARNs
- [ ] Monitor access via CloudTrail

### ❌ DON'T
- [ ] Use overly broad permissions
- [ ] Share roles across environments
- [ ] Allow "Action": "*"
- [ ] Use inline policies for reusable logic
- [ ] Forget to remove old policies

---

## Advanced Topics

### **Conditional IAM Policies**

Restrict by environment:

```json
{
  "Effect": "Allow",
  "Action": "s3:GetObject",
  "Resource": "arn:aws:s3:::bucket/*",
  "Condition": {
    "StringEquals": {
      "aws:RequestedRegion": "us-east-1"
    }
  }
}
```

### **Cross-Account Access**

For multi-account setups:

```json
{
  "Effect": "Allow",
  "Principal": {
    "AWS": "arn:aws:iam::ACCOUNT2:role/role-name"
  },
  "Action": "sts:AssumeRole"
}
```

---

## Related Documentation

- [AWS IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [Terraform IAM Module](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)
- [Systems Manager IAM Permissions](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-getting-started-instance-profile.html)
- [Main Terraform README](../README.md)

---

**Last Updated**: August 3, 2026 | **Version**: 1.0 | **Maintainer**: DevOps Team
