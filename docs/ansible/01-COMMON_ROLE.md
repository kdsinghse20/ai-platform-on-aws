# Common Role - System Setup

**OS-level configuration and system dependencies.**

See detailed documentation: `../../ansible/roles/common/README.md`

---

## Overview

Prepares Ubuntu 24.04 instances with:
- System package updates
- Core dependencies
- Python installation
- System configuration

---

## Tasks

- Update apt packages
- Install system dependencies (curl, wget, git, vim)
- Install Python 3 and pip
- Configure sudoers
- Set timezone
- Install monitoring tools

---

## When to Use

Required before any other role runs.

---

## Execution

```bash
ansible-playbook playbooks/common.yml -i inventory/hosts.yml
```

---

For complete documentation, see:
`../../ansible/roles/common/README.md`

---

**Last Updated**: August 3, 2026 | **Version**: 1.0
