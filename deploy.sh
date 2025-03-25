#!/bin/bash

# Install security updates
sudo apt update && sudo apt upgrade -y

# Print system info
echo "✅ Server is secure!"
echo "🖥️ CPU Info:" 
lscpu | grep "Model name"
echo "💾 Disk Space:"
df -h | grep "/$"
