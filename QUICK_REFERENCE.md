# AI Platform - Quick Reference Card

**Quick lookup for common operations and commands**

---

## 🚀 Deployment (First Time)

```bash
# 1. Setup Terraform
cd terraform/environments/dev
terraform init

# 2. Review & Deploy
terraform plan
terraform apply

# 3. Generate Ansible Inventory
terraform output -raw ansible_inventory > ../../../ansible/inventory/hosts.yml

# 4. Configure Services
cd ../../../ansible
ansible-playbook playbooks/site.yml -i inventory/hosts.yml

# 5. Verify
ansible all -i inventory/hosts.yml -m ping
```

---

## 🔍 Verification Commands

```bash
# Check Ollama API
curl -s http://10.0.20.x:11434/api/tags | python3 -m json.tool

# Check OpenWebUI
curl -s http://10.0.10.x:8080

# Check NGINX
ssh -i key ubuntu@10.0.10.x
nginx -t
systemctl status nginx

# Check ALB Health
aws elbv2 describe-target-health --target-group-arn arn:aws:...

# Test via Ansible
ansible all -i inventory/hosts.yml -m ping
```

---

## 🛠️ Common Terraform Commands

```bash
cd terraform/environments/dev

# View status
terraform state list
terraform output

# Plan changes
terraform plan
terraform plan -out=tfplan

# Apply changes
terraform apply tfplan

# Destroy (DANGEROUS!)
terraform destroy

# Refresh state
terraform refresh

# Format code
terraform fmt -recursive

# Validate
terraform validate
```

---

## ⚙️ Common Ansible Commands

```bash
cd ansible

# Run all playbooks
ansible-playbook playbooks/site.yml -i inventory/hosts.yml

# Run specific playbook
ansible-playbook playbooks/ollama.yml -i inventory/hosts.yml

# Run specific host
ansible-playbook playbooks/site.yml -i inventory/hosts.yml --limit ollama

# Dry-run
ansible-playbook playbooks/site.yml -i inventory/hosts.yml --check

# Verbose output
ansible-playbook playbooks/site.yml -i inventory/hosts.yml -vvv

# Test connectivity
ansible all -i inventory/hosts.yml -m ping
```

---

## 📊 AWS CLI Lookups

```bash
# List instances
aws ec2 describe-instances --filters "Name=instance-state-name,Values=running"

# Get instance IPs
aws ec2 describe-instances --instance-ids i-xxx \
  --query 'Reservations[0].Instances[0].PrivateIpAddress'

# List load balancers
aws elbv2 describe-load-balancers

# Get ALB DNS
aws elbv2 describe-load-balancers --load-balancer-arns arn:... \
  --query 'LoadBalancers[0].DNSName'

# Check target health
aws elbv2 describe-target-health --target-group-arn arn:...

# View security groups
aws ec2 describe-security-groups --group-ids sg-xxx

# Check VPC
aws ec2 describe-vpcs --vpc-ids vpc-xxx
```

---

## 🔐 AWS Systems Manager (SSH Alternative)

```bash
# Start session (no SSH needed!)
aws ssm start-session --target i-xxxxxxxxx

# Run command
aws ssm send-command \
  --instance-ids i-xxxxxxxxx \
  --document-name "AWS-RunShellScript" \
  --parameters 'commands=["docker ps"]'

# Port forwarding (SSH tunnel)
aws ssm start-session --target i-xxxxxxxxx \
  --document-name AWS-StartPortForwardingSession \
  --parameters "portNumber=22"
```

---

## 📋 Infrastructure Status Checks

```bash
# Everything healthy?
terraform state list | wc -l        # Count resources
aws ec2 describe-instances \
  --filters Name=instance-state-name,Values=running  # Running instances
aws elbv2 describe-target-health --target-group-arn arn:...  # Target health

# Network connectivity?
ansible all -m ping -i inventory/hosts.yml

# Services running?
ansible ollama -m shell -a "systemctl status ollama" -i inventory/hosts.yml
ansible openwebui -m shell -a "docker ps" -i inventory/hosts.yml
```

---

## 🐛 Quick Troubleshooting

### Can't reach application
```bash
# 1. Check ALB is running
aws elbv2 describe-load-balancers

# 2. Check targets are healthy
aws elbv2 describe-target-health --target-group-arn arn:...

# 3. Check security group allows traffic
aws ec2 describe-security-groups --group-ids sg-alb

# 4. Test NGINX on instance
aws ssm start-session --target i-openwebui
curl http://localhost:80
```

### Can't SSH
```bash
# Don't use SSH! Use SSM instead
aws ssm start-session --target i-xxxxxxxxx

# Verify instance has SSM role
aws ec2 describe-instances --instance-ids i-xxx \
  --query 'Reservations[0].Instances[0].IamInstanceProfile'
```

### Ollama not responding
```bash
# SSH into Ollama instance
aws ssm start-session --target i-ollama

# Check status
systemctl status ollama
journalctl -u ollama -n 50

# Check port
lsof -i :11434

# Test API
curl -s http://localhost:11434/api/tags
```

### Can't run Ansible
```bash
# Test connectivity
ansible all -m ping -i inventory/hosts.yml

# Check inventory
cat inventory/hosts.yml

# Test with verbose
ansible all -m ping -i inventory/hosts.yml -vvv
```

---

## 🗺️ File Locations

```
Key Files:

Terraform State:         terraform/environments/dev/terraform.tfstate
Ansible Inventory:       ansible/inventory/hosts.yml
Ollama Models:          /var/lib/ollama/models (on instance)
OpenWebUI Data:         /app/backend/data (in Docker)
NGINX Config:           /etc/nginx/nginx.conf (on instance)
NGINX Logs:             /var/log/nginx/ (on instance)

Documentation:          ARCHITECTURE.md
Terraform Docs:         terraform/README.md
Ansible Docs:           ansible/README.md
```

---

## 📈 Port Reference

```
External:
- 80    → ALB (HTTP → HTTPS redirect)
- 443   → ALB (HTTPS/TLS)

Internal:
- 8080  → OpenWebUI application
- 11434 → Ollama API
- 22    → SSH (AWS Systems Manager only)
- 80    → NGINX (reverse proxy)
```

---

## 💰 Cost Estimation

```
Monthly Costs (Approximate):
- VPC:                    ~$0
- NAT Gateways (2):       ~$64
- ALB:                    ~$22
- EC2 t3.large (2):       ~$150
- EBS (100 GB gp3):       ~$15
- Data Transfer:          ~$5

Total:                    ~$256/month (minimal usage)
```

---

## 📚 Documentation Quick Links

| Topic | Document |
|-------|----------|
| **Architecture** | [ARCHITECTURE.md](ARCHITECTURE.md) |
| **Terraform** | [terraform/README.md](terraform/README.md) |
| **Ansible** | [ansible/README.md](ansible/README.md) |
| **Navigation** | [DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md) |
| **Summary** | [DOCUMENTATION_SUMMARY.md](DOCUMENTATION_SUMMARY.md) |

---

## ✅ Pre-Deployment Checklist

- [ ] AWS account configured
- [ ] Terraform v1.0+ installed
- [ ] Ansible installed
- [ ] ACM certificate created
- [ ] Route53 domain configured
- [ ] AWS credentials working
- [ ] VPN/SSH access ready (optional)

---

## 🔄 Daily Operations

```bash
# Morning - Check health
ansible all -m ping -i ansible/inventory/hosts.yml
aws elbv2 describe-target-health --target-group-arn arn:...

# Before changes - Create backup
cd terraform/environments/dev
cp terraform.tfstate terraform.tfstate.backup

# After changes - Verify
terraform apply
ansible-playbook playbooks/site.yml -i ansible/inventory/hosts.yml

# Evening - Review logs
journalctl -u ollama
docker logs open-webui
tail -f /var/log/nginx/access.log
```

---

## 🎯 Common Goals & How to Achieve Them

### Scale OpenWebUI
```bash
# In Terraform - change instance type
# terraform/environments/dev/main.tf
instance_type = "t3.xlarge"

# Apply
terraform apply

# Reconfigure with Ansible
ansible-playbook playbooks/openwebui.yml
```

### Add new model to Ollama
```bash
# Via Ansible variable
# ansible/inventory/group_vars/ollama.yml
ollama_models:
  - gemma:3
  - llama2:latest
  - neural-chat:latest  # New model

# Run playbook
ansible-playbook playbooks/ollama.yml
```

### Enable HTTPS with custom domain
```bash
# 1. Create ACM certificate
aws acm request-certificate --domain-name yourdomain.com

# 2. Update Terraform
# terraform/environments/dev/terraform.tfvars
certificate_arn = "arn:aws:acm:..."

# 3. Apply
terraform apply

# 4. Create Route53 record (or use ALB DNS)
aws route53 change-resource-record-sets ...
```

### Monitor resource usage
```bash
# CPU
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --dimensions Name=InstanceId,Value=i-xxx \
  --period 3600 --statistics Average

# Network
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name NetworkIn \
  --dimensions Name=InstanceId,Value=i-xxx \
  --period 3600 --statistics Sum
```

---

## 🚨 Emergency Commands

```bash
# Stop everything
terraform destroy

# Restore from backup
cp terraform.tfstate.backup terraform.tfstate
terraform refresh

# Force new deployment
terraform taint module.openwebui
terraform apply

# Kill stuck instance
aws ec2 terminate-instances --instance-ids i-xxx

# Unlock state (if locked)
terraform force-unlock LOCK_ID
```

---

## 📞 Getting Help

1. **Architecture questions** → [ARCHITECTURE.md](ARCHITECTURE.md)
2. **Terraform issues** → [terraform/README.md - Troubleshooting](terraform/README.md#troubleshooting)
3. **Ansible issues** → [ansible/README.md - Troubleshooting](ansible/README.md#troubleshooting)
4. **Specific module issues** → Module-specific README
5. **Navigation help** → [DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md)

---

## 💡 Pro Tips

1. **Always plan before apply**: `terraform plan -out=tfplan`
2. **Use inventory tags for grouping**: `ansible ... --limit ollama`
3. **Check state before modifying**: `terraform state list`
4. **Test Ansible with --check**: `ansible-playbook ... --check`
5. **Monitor after changes**: `watch aws elbv2 describe-target-health ...`
6. **Use AWS Systems Manager instead of SSH**: `aws ssm start-session`
7. **Keep backups**: `cp terraform.tfstate terraform.tfstate.backup`
8. **Document your changes**: Update relevant README sections

---

## ⏱️ Time Estimates

| Task | Time |
|------|------|
| Initial deployment | 20-30 min |
| Configuration with Ansible | 10-15 min |
| Full verification | 5-10 min |
| Model download (first run) | 5-15 min |
| Infrastructure updates | 5-10 min |
| Troubleshooting | 10-30 min |

---

**Print this page for quick reference during operations!**

*For detailed information, see [DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md)*

---

**Last Updated**: August 3, 2026 | **Version**: 1.0
