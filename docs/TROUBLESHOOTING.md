# Troubleshooting Guide

**Common issues and solutions.**

---

## By Symptom

### Can't Reach Application via Browser

**Symptoms**: Browser timeout or connection refused

**Solutions**:
1. Check ALB status: `aws elbv2 describe-load-balancers`
2. Verify target health: `aws elbv2 describe-target-health --target-group-arn arn:...`
3. Check security groups allow ports 80/443
4. Verify Route53 DNS resolves correctly

### Ollama API Not Responding

**Symptoms**: `curl` to Ollama port times out

**Solutions**:
1. SSH to Ollama instance via SSM
2. Check service: `systemctl status ollama`
3. Check port: `lsof -i :11434`
4. View logs: `journalctl -u ollama -n 50`
5. Verify security group allows OpenWebUI

### OpenWebUI Can't Connect to Ollama

**Symptoms**: "Cannot reach Ollama" error in web UI

**Solutions**:
1. Verify Ollama is running on Ollama instance
2. Check OpenWebUI → Ollama security group rule
3. Check network connectivity (same VPC)
4. Check OpenWebUI logs: `docker logs open-webui`

### Models Won't Download

**Symptoms**: Model pull hangs or fails

**Solutions**:
1. Check disk space: `df -h`
2. Verify outbound internet: `curl -I https://ollama.ai`
3. Check NAT Gateway status
4. View Ollama logs for details

### Can't SSH to Instances

**Symptoms**: SSH connection refused

**Solution**: Use AWS Systems Manager instead!
```bash
aws ssm start-session --target i-xxxxxxxxx
```

### NGINX Not Working

**Symptoms**: Port 80/443 not responding

**Solutions**:
1. SSH via SSM to OpenWebUI instance
2. Test NGINX: `nginx -t`
3. Check status: `systemctl status nginx`
4. View config: `cat /etc/nginx/nginx.conf`
5. Check logs: `tail -f /var/log/nginx/error.log`

---

## By Component

### Terraform Issues

**"No valid credential sources found"**
- Configure AWS: `aws configure`
- Or export env vars: `AWS_ACCESS_KEY_ID=...`

**"Error acquiring the state lock"**
- Another process is running Terraform
- Wait or force unlock (carefully)

**"Permission denied"**
- Verify IAM user/role has required permissions

See `terraform/README.md` for more details.

### Ansible Issues

**"Failed to connect to host"**
- Test connectivity: `ansible all -m ping`
- Check security groups
- Verify instance is running

**"Permission denied (publickey)"**
- SSM access, not SSH keys!
- Use Systems Manager

**Playbook hangs**
- Run with verbose: `-vvv`
- Check for interactive prompts
- Check instance resources

See `ansible/README.md` for more details.

### AWS Issues

**ALB Target Unhealthy**
- Check health check response
- Verify NGINX/OpenWebUI running
- Check security groups

**NAT Gateway Issue**
- Check status: `aws ec2 describe-nat-gateways`
- Verify route tables
- Check EIP allocation

---

## Quick Diagnostics

```bash
# Check infrastructure
terraform state list

# Check connectivity
ansible all -m ping

# Check services
ssh to instance via SSM
systemctl status ollama
systemctl status openwebui
systemctl status nginx

# Check logs
journalctl -u ollama -f
docker logs open-webui
tail -f /var/log/nginx/error.log

# Test APIs
curl http://localhost:11434/api/tags
curl http://localhost:8080
```

---

## When to Redeploy

**Recreate Infrastructure**:
```bash
terraform destroy
terraform apply
```

**Reconfigure Services**:
```bash
ansible-playbook playbooks/site.yml
```

**Redeploy Specific Role**:
```bash
ansible-playbook playbooks/ollama.yml
```

---

For detailed module troubleshooting:
- **Terraform modules**: See `terraform/` docs
- **Ansible roles**: See `ansible/` docs
- **Architecture**: See `01-ARCHITECTURE.md`

---

**Last Updated**: August 3, 2026 | **Version**: 1.0
