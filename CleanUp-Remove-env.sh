#!/bin/bash
source aws_kali_env_vars.sh

# Terminate EC2 Instance
echo "Terminating EC2 Instance..."
aws ec2 terminate-instances --instance-ids $INSTANCE_ID

# Wait for the instance to terminate
aws ec2 wait instance-terminated --instance-ids $INSTANCE_ID

# Detach and delete Internet Gateway
echo "Deleting Internet Gateway..."
aws ec2 detach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID
aws ec2 delete-internet-gateway --internet-gateway-id $IGW_ID

# Delete Subnet
echo "Deleting Subnet..."
aws ec2 delete-subnet --subnet-id $SUBNET_ID

# Delete VPC
echo "Deleting VPC..."
aws ec2 delete-vpc --vpc-id $VPC_ID

echo "Environment cleaned up."
