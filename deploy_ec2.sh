#!/bin/bash

# --- AWS Configuration ---
source ./config.sh || { echo "❌ Missing config.sh"; exit 1; }

# --- Launch Instance ---
echo "🚀 Launching AppServer..."
INSTANCE_ID=$(aws ec2 run-instances \
  --image-id "$AMI_ID" \
  --instance-type "$INSTANCE_TYPE" \
  --key-name "$KEY_NAME" \
  --security-group-ids "$SECURITY_GROUP_ID" \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=AppServer}]' \
  --query 'Instances[0].InstanceId' \
  --output text)

if [ -z "$INSTANCE_ID" ]; then
    echo "❌ Failed to launch instance!"
    exit 1
fi

# --- Get IP ---
PUBLIC_IP=$(aws ec2 describe-instances \
  --instance-ids "$INSTANCE_ID" \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)

if [ -z "$PUBLIC_IP" ]; then
    echo "❌ Failed to get IP address!"
    exit 1
fi

# --- Secure Server ---
echo "🔐 Securing AppServer..."
ssh -i ~/"$KEY_NAME".pem -o "StrictHostKeyChecking=no" ubuntu@"$PUBLIC_IP" <<EOF
sudo apt-get update -qq && sudo apt-get upgrade -y -qq
EOF || { echo "❌ SSH command failed"; exit 1; }

# --- Output ---
echo "✅ AppServer Ready!"
echo "🌐 Public IP: $PUBLIC_IP"
echo "🔑 SSH: ssh -i ~/$KEY_NAME.pem ubuntu@$PUBLIC_IP"
echo "💻 Terminate with: aws ec2 terminate-instances --instance-ids $INSTANCE_ID"
