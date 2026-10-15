# DevOps Deploy Project

A simple Python Flask + PostgreSQL app, deployed to AWS step by step: first by hand, then fully automated. The app is deliberately small; the focus is on **deployment, automation and operations**.

## Architecture

```
Browser -> AWS Security Group (port 80) -> Nginx (reverse proxy)
        -> Gunicorn (2 workers, 127.0.0.1:5000, managed by systemd)
        -> Flask app -> PostgreSQL
Nightly cron -> pg_dump -> gzip -> S3 (via IAM role, no stored keys)
```

## Tech stack

| Area | Tools |
|---|---|
| Cloud | AWS EC2, VPC, subnets, Internet Gateway, route tables, security groups, IAM roles, S3 |
| OS | Ubuntu Linux |
| App | Python, Flask, PostgreSQL |
| Web serving | Gunicorn, Nginx |
| Process management | systemd |
| Automation | Ansible (roles, handlers, Vault) |
| Scripting | Bash, cron, AWS CLI |
| Version control | Git, GitHub |

## Repository structure

```
app.py                     Flask app (/ and /health endpoints)
requirements.txt           Python dependencies
deploy/
  devops-app.service       systemd unit (Gunicorn, auto-restart, start on boot)
  nginx-devops-app.conf    Nginx reverse proxy config
ansible/
  inventory.ini            Target servers
  site.yml                 Applies the roles below
  group_vars/webservers/   Variables + Vault-encrypted secrets
  roles/                   common, postgres, app, nginx
scripts/
  backup_db.sh             PostgreSQL backup to S3
```

## Deploy with Ansible

From a control node that can reach the target over SSH:

```bash
cd ansible
ansible-playbook -i inventory.ini site.yml --ask-vault-pass
```

The playbook installs packages, creates the PostgreSQL user and database, clones this repo, builds the virtualenv, writes a root-only environment file, and installs the systemd and Nginx configs. Re-running it is idempotent (`changed=0`).

## Reliability and security

- Runs as a systemd service with `Restart=always` and `enable`, so it recovers from crashes and reboots (tested with `kill -9` and `sudo reboot`).
- Gunicorn binds to `127.0.0.1`; only Nginx is exposed on port 80.
- Database credentials live in a `chmod 600` env file loaded by systemd, and in Ansible Vault, never in plain text in the playbook.
- The server accesses S3 through an IAM role, with no access keys on disk.
- AWS account protected with MFA, an IAM admin user and a zero-spend budget alert. SSH is limited to my IP.

## Backups

`scripts/backup_db.sh` runs nightly via cron (`0 2 * * *`), dumps the database with `pg_dump`, compresses it and uploads it to S3. An S3 lifecycle rule can expire old backups.

## Problems I solved

- App died when the terminal closed: moved it to a systemd service.
- Flask development server warning: switched to Gunicorn behind Nginx.
- DB table not created under Gunicorn: moved `init_db()` out of `if __name__ == "__main__"`.
- Site timed out although the app answered locally: traced it to a missing HTTP rule in the security group.
- cron could not find `aws`: set `PATH` inside the backup script.

## Roadmap

- [x] Manual deployment on EC2 (systemd, Gunicorn, Nginx)
- [x] Custom VPC, IAM role, S3
- [x] Ansible roles + Vault, automated backups
- [ ] Docker + Docker Compose
- [ ] CI/CD with GitHub Actions
- [ ] Infrastructure as Code with Terraform
- [ ] Kubernetes, Helm, Prometheus + Grafana
