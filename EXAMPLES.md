# Remote SSH Manager - Examples

## Basic Usage

### Setting up a session

```bash
# Open a new SSH session with ID "prod"
remote open prod user@production.server.com

# Save credentials for automatic reconnection
remote save staging deploy@staging.server.com mypassword

# List all sessions
remote list

# List saved sessions
remote saved
```

## File Transfers

### Simple transfers

```bash
# Download a file to current directory
remote download prod /var/log/app.log

# Download to specific location
remote download prod /var/log/app.log ~/logs/app-prod.log

# Upload a file
remote upload prod backup.tar.gz /backups/

# Upload to specific location
remote upload prod config.json /etc/myapp/config.json
```

### Advanced options

```bash
# Download with compression (useful for text files)
remote download prod /var/log/large.log --compress

# Disable resume (start fresh)
remote download prod /data/file.bin --no-resume

# Skip verification (faster but less safe)
remote upload prod large-file.iso /tmp/ --no-verify

# Quiet mode (less output)
remote download prod /data/export.csv --quiet
```

## Server-to-Server Transfers

### Transfer modes

```bash
# Default: proxy mode (stream through local machine)
remote transfer prod /data/backup.tar.gz backup /archives/

# Direct mode (faster, creates temporary SSH key)
remote transfer prod /huge/file.bin storage /backups/ direct

# Local mode (download then upload)
remote transfer web /var/www/site.tar.gz archive /websites/ local
```

### With options

```bash
# Transfer with compression
remote transfer db1 /backup/dump.sql db2 /restore/ --compress

# Skip verification for speed
remote transfer media /videos/large.mp4 cdn /content/ --no-verify

# Auto-confirm direct mode (skip security prompt)
remote transfer source /data/file target /dest/ direct -y
```

## Remote Commands

```bash
# Run simple command
remote exec prod "df -h"

# Run complex command
remote exec prod "cd /var/log && tail -f app.log"

# Run command with pipes
remote exec prod "ps aux | grep nginx"

# Run sudo command (will prompt for password)
remote exec prod "sudo systemctl restart nginx"
```

## Background Jobs

```bash
# Start a large download in background
remote download prod /backups/database.dump

# List all background jobs
remote progress list

# Check specific job progress
remote progress job.ABC123XYZ

# Clean old completed jobs
remote progress clean
```

## Session Management

```bash
# Close specific session
remote close prod

# Close all sessions
remote close-all

# Remove saved credentials
remote forget staging
```

## Real-World Scenarios

### Backup Script

```bash
#!/bin/bash
# Daily backup script

# Open connections
remote open db database@db.server.com
remote open backup backup@storage.server.com

# Create backup on database server
remote exec db "mysqldump --all-databases > /tmp/backup-$(date +%Y%m%d).sql"

# Transfer to backup server
remote transfer db /tmp/backup-$(date +%Y%m%d).sql backup /backups/mysql/

# Cleanup
remote exec db "rm /tmp/backup-$(date +%Y%m%d).sql"
remote close-all
```

### Log Collection

```bash
# Collect logs from multiple servers
for server in web1 web2 web3; do
    remote open $server admin@$server.example.com
    remote download $server /var/log/nginx/access.log logs/$server-access.log --compress
done

# Merge logs
cat logs/*-access.log | sort > logs/merged-access.log

remote close-all
```

### Deploy Script

```bash
#!/bin/bash
# Deploy application to multiple servers

SERVERS="app1 app2 app3"
DEPLOY_FILE="myapp-v2.0.tar.gz"

# Upload to all servers
for server in $SERVERS; do
    remote open $server deploy@$server.prod.com
    remote upload $server $DEPLOY_FILE /opt/deployments/ &
done

# Wait for uploads
wait

# Extract and restart on all servers
for server in $SERVERS; do
    remote exec $server "cd /opt/deployments && tar -xzf $DEPLOY_FILE"
    remote exec $server "sudo systemctl restart myapp"
done

remote close-all
```

## Tips and Tricks

### Using with SSH config

If you have `~/.ssh/config` set up:

```bash
# Works with SSH config aliases
remote open myserver myalias

# Where ~/.ssh/config contains:
# Host myalias
#     HostName server.example.com
#     User myuser
#     Port 2222
```

### Checking transfer integrity

```bash
# Get hash on source
remote exec source "sha256sum /data/important.dat"

# Transfer
remote transfer source /data/important.dat dest /backup/

# Verify on destination
remote exec dest "sha256sum /backup/important.dat"
```

### Monitoring transfers

```bash
# In terminal 1: start transfer
remote upload prod huge-file.bin /data/

# In terminal 2: monitor progress
watch remote progress list
```