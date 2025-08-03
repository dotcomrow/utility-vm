#!/bin/bash
echo "🔧 Creating manual Harbor backup before VM recreation..."
echo "This script will backup Harbor configuration to the persistent disk"

# Check if Harbor is running
if ! docker-compose -f /opt/harbor/docker-compose.yml ps | grep -q "Up"; then
    echo "⚠️  Harbor is not running, starting it first..."
    cd /opt/harbor
    docker-compose up -d
    sleep 30
fi

# Create backup directory on persistent disk
mkdir -p /data/harbor/manual_backup

# Backup current Harbor configuration
echo "📋 Backing up Harbor configuration..."
if [ -f "/opt/harbor/harbor.yml" ]; then
    cp /opt/harbor/harbor.yml /data/harbor/harbor.yml.backup
    cp /opt/harbor/harbor.yml /data/harbor/manual_backup/harbor.yml.$(date +%Y%m%d_%H%M%S)
    echo "✅ Harbor configuration backed up to /data/harbor/harbor.yml.backup"
else
    echo "❌ Harbor configuration not found at /opt/harbor/harbor.yml"
fi

# Backup Docker Compose configuration
if [ -f "/opt/harbor/docker-compose.yml" ]; then
    cp /opt/harbor/docker-compose.yml /data/harbor/manual_backup/docker-compose.yml.$(date +%Y%m%d_%H%M%S)
    echo "✅ Docker Compose configuration backed up"
fi

# Check what data already exists on persistent disk
echo ""
echo "�� Current persistent disk contents:"
ls -la /data/harbor/
echo ""

# Show disk usage
echo "💾 Persistent disk usage:"
df -h /data/harbor/
echo ""

# Check for existing Harbor data
if [ -d "/data/harbor/database" ]; then
    echo "✅ Harbor database data found on persistent disk"
else
    echo "⚠️  No Harbor database data found - this might be a fresh installation"
fi

if [ -d "/data/harbor/registry" ]; then
    echo "✅ Harbor registry data found on persistent disk"
    echo "📦 Registry size: $(du -sh /data/harbor/registry/ | cut -f1)"
else
    echo "⚠️  No Harbor registry data found"
fi

# Create a summary file
cat > /data/harbor/backup_summary.txt << SUMMARY
Harbor Manual Backup Summary
Created: $(date)
Hostname: $(hostname)
Harbor Version: $(docker-compose -f /opt/harbor/docker-compose.yml exec core harbor_version 2>/dev/null || echo "Unable to determine")

Backed up files:
- harbor.yml -> /data/harbor/harbor.yml.backup
- docker-compose.yml -> /data/harbor/manual_backup/

Persistent data directories:
$(ls -la /data/harbor/ | grep ^d)

Total persistent disk usage: $(df -h /data/harbor/ | tail -1 | awk '{print $3}')
SUMMARY

echo "✅ Backup summary created at /data/harbor/backup_summary.txt"
echo ""
echo "🎉 Manual backup completed!"
echo "📋 Summary:"
cat /data/harbor/backup_summary.txt
