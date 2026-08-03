# ALB Module - Application Load Balancer

Manages AWS Application Load Balancer with HTTPS termination and traffic routing.

---

## Overview

This module creates:
- **Application Load Balancer**: Public load balancer in public subnets
- **Target Groups**: Routes traffic to OpenWebUI instance
- **Listeners**: HTTP (redirect to HTTPS) and HTTPS
- **Health Checks**: Monitors instance health
- **DNS Integration**: Links with Route53 (if configured)

---

## Architecture

```
┌────────────────────────────┐
│  Internet Users            │
│  (HTTPS requests)          │
└─────────────┬──────────────┘
              │
              ▼
    ┌─────────────────────┐
    │  AWS ALB (Public)   │
    │  Ports: 80, 443     │
    └──────────┬──────────┘
               │
         ┌─────┴─────┐
         │           │
         ▼           ▼
    ┌──────┐    ┌──────┐
    │ HTTP │    │HTTPS │
    │ :80  │    │ :443 │
    └──────┘    └──┬───┘
         │          │
         └──────┬───┘
                │
          ┌─────▼──────┐
          │ TLS/SSL    │
          │ Offloading │
          └─────┬──────┘
                │
          ┌─────▼──────────────────┐
          │ Target Group           │
          │ (Health Checks)        │
          └─────┬──────────────────┘
                │
          ┌─────▼──────────────────────┐
          │ OpenWebUI Instance         │
          │ :8080 (via NGINX :80)     │
          └────────────────────────────┘
```

---

## Input Variables

| Variable | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `project_name` | string | - | ✅ Yes | Project identifier |
| `environment` | string | - | ✅ Yes | Environment (dev, staging, prod) |
| `vpc_id` | string | - | ✅ Yes | VPC ID |
| `public_subnet_ids` | list(string) | - | ✅ Yes | Public subnet IDs (2+) |
| `alb_security_group_id` | string | - | ✅ Yes | ALB security group ID |
| `target_instance_id` | string | - | ✅ Yes | OpenWebUI instance ID |
| `certificate_arn` | string | - | ✅ Yes | ACM certificate ARN for HTTPS |

---

## Output Values

| Output | Type | Description |
|--------|------|-------------|
| `alb_id` | string | Load balancer ID |
| `alb_arn` | string | Load balancer ARN |
| `alb_dns_name` | string | DNS name (e.g., ai-platform-xxx.elb.us-east-1.amazonaws.com) |
| `alb_zone_id` | string | Zone ID (for Route53) |
| `target_group_arn` | string | Target group ARN |
| `target_group_name` | string | Target group name |

---

## Resource Details

### **Application Load Balancer**

**Configuration**:
- **Type**: Application (Layer 7)
- **Scheme**: `internet-facing` (public)
- **Subnets**: Distributed across public subnets
- **Security Groups**: Restricted to ALB SG
- **Logging**: Access logs optional

**Capabilities**:
- Path-based routing
- Host-based routing
- SSL/TLS termination
- Health checks
- Auto-scaling support

### **Target Groups**

**Configuration**:
- **Protocol**: HTTP (to backend)
- **Port**: 80 (NGINX on OpenWebUI)
- **VPC**: Specified VPC
- **Target Type**: Instance

**Health Check**:
- **Protocol**: HTTP
- **Path**: `/` (root)
- **Port**: 80
- **Interval**: 30 seconds
- **Timeout**: 5 seconds
- **Healthy Threshold**: 2
- **Unhealthy Threshold**: 2
- **Matcher**: 200-399 (HTTP response codes)

### **Listeners**

#### **HTTP Listener (Port 80)**
- Automatically redirects to HTTPS
- No HTTPS errors, smooth migration

#### **HTTPS Listener (Port 443)**
- Uses ACM certificate (provided via `certificate_arn`)
- Protocol: HTTPS/SSL
- TLS version: TLSv1.2+
- Routes to target group

---

## Usage Example

```hcl
module "alb" {
  source = "../../modules/alb"

  project_name = "ai-platform"
  environment  = "dev"

  vpc_id = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  
  alb_security_group_id = module.security_groups.alb_security_group_id
  target_instance_id = module.openwebui.instance_id
  
  certificate_arn = "arn:aws:acm:us-east-1:ACCOUNT:certificate/CERT_ID"
}
```

---

## SSL/TLS Configuration

### **ACM Certificate (Pre-requisite)**

Certificate must be created before deploying this module:

```bash
# Request certificate
aws acm request-certificate \
  --domain-name ai.example.com \
  --domain-name "*.ai.example.com" \
  --validation-method DNS

# List certificates
aws acm list-certificates --region us-east-1

# Validate DNS records
# Add CNAME records to Route53 for validation
```

### **Certificate Binding**

ALB automatically uses certificate from `certificate_arn`:
- No certificate renewal needed (ACM manages it)
- Automatic rotation before expiry
- Multiple domains supported (via SANs)

### **Security**

- **Protocols**: TLSv1.2, TLSv1.3 (current best practice)
- **Ciphers**: Modern ciphers, strong encryption
- **Forward Secrecy**: Enabled
- **Rating**: A+ on SSL Labs (typical)

---

## DNS Integration

### **Route53 (Optional)**

To use custom domain instead of ALB DNS name:

```bash
# Create alias record
aws route53 change-resource-record-sets \
  --hosted-zone-id ZONE_ID \
  --change-batch '{
    "Changes": [{
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "ai.example.com",
        "Type": "A",
        "AliasTarget": {
          "HostedZoneId": "'$ALB_ZONE_ID'",
          "DNSName": "'$ALB_DNS_NAME'",
          "EvaluateTargetHealth": true
        }
      }
    }]
  }'
```

### **Traffic Flow**

```
User → Route53 → ALB DNS → ALB → Target Group → OpenWebUI
```

---

## Health Checks

### **How It Works**

1. ALB sends HTTP request to instance on port 80
2. Instance responds with status code
3. If status in 200-399 range → Healthy
4. If 2 consecutive healthy checks → registered
5. If 2 consecutive failures → de-registered

### **Testing Manually**

```bash
# From ALB perspective
curl -I http://10.0.10.x:80  # Should return 200+

# Check target health
aws elbv2 describe-target-health \
  --target-group-arn arn:aws:elasticloadbalancing:...
```

### **Monitoring**

```bash
# CloudWatch metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApplicationELB \
  --metric-name HealthyHostCount \
  --dimensions Name=TargetGroup,Value=targetgroup/... \
  --start-time 2026-08-01T00:00:00Z \
  --end-time 2026-08-03T00:00:00Z \
  --period 300 \
  --statistics Average
```

---

## Terraform Code Structure

```hcl
# Application Load Balancer
resource "aws_lb" "main"

# Target Group
resource "aws_lb_target_group" "main"

# Target Group Attachment
resource "aws_lb_target_group_attachment" "main"

# HTTP Listener (redirect)
resource "aws_lb_listener" "http"

# HTTPS Listener
resource "aws_lb_listener" "https"

# Listener rule for path routing (optional)
resource "aws_lb_listener_rule" "example"
```

---

## Common Operations

### **View ALB Details**

```bash
# List load balancers
aws elbv2 describe-load-balancers

# Get specific ALB
aws elbv2 describe-load-balancers \
  --load-balancer-arns arn:aws:elasticloadbalancing:...

# Check DNS name
aws elbv2 describe-load-balancers --query 'LoadBalancers[0].DNSName'
```

### **Monitor Target Health**

```bash
# Check target status
aws elbv2 describe-target-health \
  --target-group-arn arn:aws:elasticloadbalancing:...

# Expected output: "TargetHealth": { "State": "healthy" }
```

### **View Access Logs** (if enabled)

```bash
# List logs in S3
aws s3 ls s3://alb-logs-bucket/AWSLogs/ACCOUNT/elasticloadbalancing/

# Download specific log
aws s3 cp s3://alb-logs-bucket/AWSLogs/.../alb_log_20260803.log .
```

---

## Monitoring & Alarms

### **Key Metrics**

```bash
# Request count
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApplicationELB \
  --metric-name RequestCount \
  --dimensions Name=LoadBalancer,Value=app/... \
  --start-time 2026-08-01T00:00:00Z \
  --end-time 2026-08-03T00:00:00Z \
  --period 300 --statistics Sum

# Response time
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApplicationELB \
  --metric-name TargetResponseTime \
  --start-time 2026-08-01T00:00:00Z \
  --end-time 2026-08-03T00:00:00Z \
  --period 300 --statistics Average

# Error responses
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApplicationELB \
  --metric-name HTTPCode_Target_5XX_Count \
  --period 300 --statistics Sum
```

### **Create CloudWatch Alarm**

```bash
aws cloudwatch put-metric-alarm \
  --alarm-name alb-unhealthy-hosts \
  --alarm-description "Alert when unhealthy host count > 0" \
  --metric-name UnHealthyHostCount \
  --namespace AWS/ApplicationELB \
  --statistic Average \
  --period 300 \
  --threshold 0 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 2
```

---

## Troubleshooting

### **ALB Not Responding**

```bash
# 1. Check ALB status
aws elbv2 describe-load-balancers --query 'LoadBalancers[0].State'

# 2. Check security group allows port 80/443
aws ec2 describe-security-groups --group-ids sg-alb

# 3. Check target health
aws elbv2 describe-target-health --target-group-arn arn:...
```

### **Targets Unhealthy**

```bash
# 1. Verify instance is running
aws ec2 describe-instances --instance-ids i-xxxxxxxxx

# 2. SSH to instance and test health check
ssh -i key ubuntu@10.0.10.x
curl -I http://localhost:80

# 3. Check security group allows ALB traffic
aws ec2 describe-security-groups --group-ids sg-openwebui

# 4. Check NGINX is running
systemctl status nginx
```

### **HTTPS Certificate Issues**

```bash
# 1. Verify certificate exists
aws acm describe-certificate --certificate-arn arn:aws:acm:...

# 2. Check certificate expiry
aws acm describe-certificate --certificate-arn arn:... \
  --query 'Certificate.NotAfter'

# 3. Verify listener has correct certificate
aws elbv2 describe-listeners --load-balancer-arn arn:... \
  --query 'Listeners[?Port==`443`].Certificates'
```

---

## Security

### ✅ Implemented

- [ ] HTTPS/TLS encryption for all traffic
- [ ] Security group restrictions
- [ ] ACM certificate management
- [ ] DDoS protection (AWS Shield Standard)
- [ ] Access logs available (optional)

### 🔒 Best Practices

- [ ] Enable access logs for audit
- [ ] Monitor health check metrics
- [ ] Use WAF for additional protection
- [ ] Enable HTTP/2 and HTTP/3
- [ ] Regular security certificate validation

---

## Cost Optimization

### **ALB Pricing** (approximate)

- **ALB Hourly**: ~$16/month
- **LCU (Load Capacity Units)**: $5.84/month (min)
- **Total Monthly**: ~$22 minimum

### **Cost Reduction**

- Use NLB for extreme throughput
- Consider Classic ELB for simple apps
- Monitor LCU consumption

---

## Best Practices

### ✅ DO
- [ ] Distribute across multiple AZs
- [ ] Monitor target health
- [ ] Use meaningful names
- [ ] Enable access logs
- [ ] Set up CloudWatch alarms
- [ ] Regular security updates
- [ ] Monitor SSL certificate expiry

### ❌ DON'T
- [ ] Use self-signed certificates
- [ ] Ignore unhealthy targets
- [ ] Expose sensitive data in logs
- [ ] Skip health check configuration
- [ ] Forget to test failover

---

## Advanced Topics

### **Path-Based Routing**

Route different paths to different targets:

```hcl
resource "aws_lb_listener_rule" "api" {
  listener_arn = aws_lb_listener.https.arn
  
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}
```

### **Host-Based Routing**

Route different domains to different targets:

```hcl
resource "aws_lb_listener_rule" "admin" {
  listener_arn = aws_lb_listener.https.arn
  
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.admin.arn
  }

  condition {
    host_header {
      values = ["admin.example.com"]
    }
  }
}
```

### **WAF Integration**

For DDoS and application-layer protection:

```hcl
resource "aws_wafv2_web_acl" "example" {
  name  = "alb-waf"
  scope = "REGIONAL"
}

resource "aws_wafv2_web_acl_association" "alb" {
  resource_arn = aws_lb.main.arn
  web_acl_arn  = aws_wafv2_web_acl.example.arn
}
```

---

## Related Documentation

- [AWS ALB Documentation](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/)
- [Terraform ALB Module](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb)
- [ACM Certificate Management](https://docs.aws.amazon.com/acm/latest/userguide/)
- [Main Terraform README](../README.md)
- [Architecture Guide](../../ARCHITECTURE.md)

---

**Last Updated**: August 3, 2026 | **Version**: 1.0 | **Maintainer**: DevOps Team
