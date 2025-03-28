#!/bin/bash

# --- Config ---
KEY_NAME="cloudops-key"              # Your key pair name
INSTANCE_ID=""                       # Paste INSTANCE_ID from deploy_ec2.sh output

# --- Get IP ---
PUBLIC_IP=$(aws ec2 describe-instances \
  --instance-ids $INSTANCE_ID \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)

[ -z "$PUBLIC_IP" ] && { echo "❌ No IP found. Check INSTANCE_ID."; exit 1; }

# --- Deploy Flask App ---
echo "🚀 Deploying Flask app to $PUBLIC_IP..."
scp -i ~/$KEY_NAME.pem -o "StrictHostKeyChecking=no" app.py ubuntu@$PUBLIC_IP:~/app.py
ssh -i ~/$KEY_NAME.pem -o "StrictHostKeyChecking=no" ubuntu@$PUBLIC_IP <<EOF
sudo apt-get update -qq
sudo apt-get install python3-venv -y -qq
python3 -m venv ~/flask_env
source ~/flask_env/bin/activate
pip install flask
nohup python3 ~/app.py &>/dev/null &
EOF

# --- Output ---
echo "✅ Flask App Deployed!"
echo "🌍 Visit: http://$PUBLIC_IP:5000"
echo "🔑 SSH: ssh -i ~/$KEY_NAME.pem ubuntu@$PUBLIC_IP"
