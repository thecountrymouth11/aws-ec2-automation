#!/bin/bash

source variables.txt || { echo "❌ Missing variables.txt"; exit 1; }

echo "🚀 Launching AppServer..."
INSTANCE_ID=$(aws ec2 run-instances \
  --region ap-south-1 \
  --image-id "$AMI_ID" \
  --instance-type "$INSTANCE_TYPE" \
  --key-name "$KEY_NAME" \
  --security-group-ids "$SECURITY_GROUP_ID" \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=AppServer}]' \
  --query 'Instances[0].InstanceId' \
  --output text 2>/dev/null)

if [ -z "$INSTANCE_ID" ]; then
    echo "❌ Failed to launch instance! Check AMI, creds, or SG."
    exit 1
fi

echo "⏳ Waiting for instance to run..."
aws ec2 wait instance-running --region ap-south-1 --instance-ids "$INSTANCE_ID"

PUBLIC_IP=$(aws ec2 describe-instances \
  --region ap-south-1 \
  --instance-ids "$INSTANCE_ID" \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)

if [ -z "$PUBLIC_IP" ]; then
    echo "❌ Failed to get IP address!"
    exit 1
fi

echo "$INSTANCE_ID" > instance_id.txt

echo "🔐 Securing AppServer..."
ssh -i ~/"$KEY_NAME".pem -o "StrictHostKeyChecking=no" ubuntu@"$PUBLIC_IP" <<EOF
sudo apt-get update -qq && sudo apt-get upgrade -y -qq
EOF || { echo "❌ SSH command failed"; exit 1; }

echo "✅ AppServer Ready!"
echo "🌐 Public IP: $PUBLIC_IP"
echo "🔑 SSH: ssh -i ~/$KEY_NAME.pem ubuntu@$PUBLIC_IP"
echo "💻 Terminate with: aws ec2 terminate-instances --instance-ids $INSTANCE_ID"
