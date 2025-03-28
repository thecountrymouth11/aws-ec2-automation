# aws-ec2-automation

scripts to launch ec2 instances and deploy a flask app. cloudops vibes all day.

## what’s here
- `deploy.sh`: logs into an ec2 instance and updates it
- `deploy_ec2.sh`: spins up a fresh ec2 instance
- `app.py`: flask web app for ec2, runs on port 5000
- `deploy_flask_app.sh`: deploys app.py to an ec2 instance (set INSTANCE_ID from deploy_ec2.sh output)

## how to use
1. run `deploy_ec2.sh` to get an instance id
2. plug that id into `deploy_flask_app.sh` and run it
3. hit the public ip:5000 in your browser
