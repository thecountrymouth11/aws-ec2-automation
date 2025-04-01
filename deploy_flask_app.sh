#!/bin/bash

# --- Config ---
KEY_NAME="cloudops-key"				#Your key pair name
INSTANCE_ID=$(cat instance_id.txt)

# --- Get IP ---
PUBLIC_IP=$(aws ec2 describe-instances \
  --instance-ids $INSTANCE_ID \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)

[ -z "$PUBLIC_IP" ] && { echo "❌ No IP. Check INSTANCE_ID."; exit 1; }

# --- Deploy Flask App ---
echo "🚀 Deploying to $PUBLIC_IP..."
scp -i ~/$KEY_NAME.pem -o "StrictHostKeyChecking=no" app.py ubuntu@$PUBLIC_IP:~/app.py
scp -i ~/$KEY_NAME.pem -o "StrictHostKeyChecking=no" Dockerfile ubuntu@$PUBLIC_IP:~/Dockerfile
ssh -i ~/$KEY_NAME.pem -o "StrictHostKeyChecking=no" ubuntu@$PUBLIC_IP <<EOF
sudo apt-get update -qq
sudo apt-get install docker.io -y -qq
sudo docker build -t flask-app .
sudo docker run -d -p 5000:5000 flask-app
EOF

# --- Output ---
echo "✅ Deployed!"
echo "🌍 Visit: http://$PUBLIC_IP:5000"
echo "🔑 SSH: ssh -i ~/$KEY_NAME.pem ubuntu@$PUBLIC_IP"
