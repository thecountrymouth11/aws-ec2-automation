#!/bin/bash

# --- AWS Configuration ---
AMI_ID="ami-0e35ddab05955cf57"       # Ubuntu 22.04 AMI (Free Tier)
INSTANCE_TYPE="t2.micro"             # Free Tier instance
KEY_NAME="cloudops-key"              # Your existing key pair name
SECURITY_GROUP_ID="sg-0cdd48e63d80415b9"

# --- Launch Instance ---
echo "🚀 Launching AppServer..."
INSTANCE_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type $INSTANCE_TYPE \
  --key-name $KEY_NAME \
  --security-group-ids $SECURITY_GROUP_ID \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=AppServer}]' \
  --query 'Instances[0].InstanceId' \
  --output text)

[ -z "$INSTANCE_ID" ] && { echo "❌ Failed to launch instance"; exit 1; }

# --- Wait for Instance ---
echo "⏳ Waiting for AppServer to initialize..."
aws ec2 wait instance-running --instance-ids $INSTANCE_ID || { echo "❌ Instance failed to start"; exit 1; }

# --- Get IP ---
PUBLIC_IP=$(aws ec2 describe-instances \
  --instance-ids $INSTANCE_ID \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)

# --- Secure Server ---
echo "🔐 Securing AppServer..."
ssh -i ~/$KEY_NAME.pem -o "StrictHostKeyChecking=no" ubuntu@$PUBLIC_IP <<EOF
sudo apt-get update -qq && sudo apt-get upgrade -y -qq
EOF

# --- Output ---
echo "✅ AppServer Ready!"
echo "🌐 Public IP: $PUBLIC_IP"
echo "🔑 SSH: ssh -i ~/$KEY_NAME.pem ubuntu@$PUBLIC_IP"
echo "💻 Terminate with: aws ec2 terminate-instances --instance-ids $INSTANCE_ID"
