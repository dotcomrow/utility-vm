#!/bin/bash
set -e

echo "🔄 Harbor Persistent Disk Recovery Setup"
echo "This script will help you create a persistent Harbor disk and recover your data"
echo ""

# Check if we're in the right directory
if [[ ! -f "utility-vm.tf" ]]; then
    echo "❌ Please run this script from the terraform/ directory"
    exit 1
fi

echo "📋 Step 1: Create Persistent Harbor Disk"
echo "----------------------------------------"

# Create the harbor disk terraform config if it doesn't exist
if [[ ! -d "terraform-harbor-disk" ]]; then
    echo "✅ Harbor disk Terraform configuration already created"
else
    echo "ℹ️  Harbor disk configuration found"
fi

cd terraform-harbor-disk

# Check if terraform.tfvars exists
if [[ ! -f "terraform.tfvars" ]]; then
    echo "📝 Creating terraform.tfvars from example..."
    cp terraform.tfvars.example terraform.tfvars
    echo "⚠️  Please edit terraform-harbor-disk/terraform.tfvars with your Proxmox settings"
    echo "   Then run this script again"
    exit 1
fi

echo "🚀 Initializing Harbor disk Terraform..."
terraform init

echo "📋 Planning Harbor disk creation..."
terraform plan

echo ""
read -p "Continue with Harbor disk creation? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Harbor disk creation cancelled"
    exit 1
fi

echo "🔧 Creating persistent Harbor disk..."
terraform apply -auto-approve

# Get the disk ID
HARBOR_DISK_ID=$(terraform output -raw harbor_disk_id)
echo "✅ Harbor persistent disk created: $HARBOR_DISK_ID"

cd ..

echo ""
echo "📋 Step 2: Configure Main VM"
echo "----------------------------"

# Update the main terraform.tfvars
if grep -q "existing_harbor_disk_id" terraform.tfvars 2>/dev/null; then
    echo "ℹ️  Updating existing_harbor_disk_id in terraform.tfvars..."
    sed -i.bak "s|existing_harbor_disk_id.*|existing_harbor_disk_id = \"$HARBOR_DISK_ID\"|" terraform.tfvars
else
    echo "➕ Adding existing_harbor_disk_id to terraform.tfvars..."
    echo "existing_harbor_disk_id = \"$HARBOR_DISK_ID\"" >> terraform.tfvars
fi

echo "✅ Main VM configuration updated"

echo ""
echo "📋 Step 3: Deploy Main VM with Persistent Disk"
echo "----------------------------------------------"

read -p "Continue with main VM creation? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "ℹ️  VM creation skipped. You can run 'terraform apply' manually later"
    echo "✅ Harbor persistent disk is ready: $HARBOR_DISK_ID"
    exit 0
fi

echo "🚀 Creating main VM with persistent Harbor disk..."
terraform apply -auto-approve

echo ""
echo "✅ Harbor VM Recreation Complete!"
echo ""
echo "📋 Summary:"
echo "  • Persistent Harbor disk: $HARBOR_DISK_ID"
echo "  • Harbor storage VM: terraform-harbor-disk/ (protected from deletion)"
echo "  • Main utility VM: terraform/ (can be destroyed/recreated safely)"
echo ""
echo "🔧 Your Harbor data should be automatically detected and restored"
echo "📦 All cached container images should be preserved"
echo "⏳ Allow 5-10 minutes for full Harbor initialization"
echo ""
echo "🔍 Monitor setup progress:"
echo "  ssh user@vm-ip 'tail -f /var/log/setup-utility.log'"
