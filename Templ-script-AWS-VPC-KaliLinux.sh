#!/bin/bash

# File to store environment variables
ENV_FILE="aws_kali_env_vars.sh"

# Function to write variables to the file
write_env() {
  echo "$1=\"$2\"" >> $ENV_FILE
}

# Step 1: Create VPC
echo "Creating VPC..."
VPC_ID=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 --query 'Vpc.VpcId' --output text)
write_env "VPC_ID" "$VPC_ID"
echo "VPC ID: $VPC_ID"

# Step 2: Create Subnet
echo "Creating Subnet..."
SUBNET_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block 10.0.1.0/24 --query 'Subnet.SubnetId' --output text)
write_env "SUBNET_ID" "$SUBNET_ID"
echo "Subnet ID: $SUBNET_ID"

# Step 3: Create Internet Gateway
echo "Creating Internet Gateway..."
IGW_ID=$(aws ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' --output text)
write_env "IGW_ID" "$IGW_ID"
echo "Internet Gateway ID: $IGW_ID"

# Attach Internet Gateway to VPC
aws ec2 attach-internet-gateway --vpc-id $VPC_ID --internet-gateway-id $IGW_ID

# Step 4: Create Route Table
echo "Creating Route Table..."
ROUTE_TABLE_ID=$(aws ec2 create-route-table --vpc-id $VPC_ID --query 'RouteTable.RouteTableId' --output text)
write_env "ROUTE_TABLE_ID" "$ROUTE_TABLE_ID"
echo "Route Table ID: $ROUTE_TABLE_ID"

# Step 5: Create route to the Internet
aws ec2 create-route --route-table-id $ROUTE_TABLE_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID

# Associate Route Table with Subnet
aws ec2 associate-route-table --route-table-id $ROUTE_TABLE_ID --subnet-id $SUBNET_ID

# Step 6: Create Security Group
echo "Creating Security Group..."
SG_ID=$(aws ec2 create-security-group --group-name kali-sg --description "Security group for Kali Linux EC2" --vpc-id $VPC_ID --query 'GroupId' --output text)
write_env "SG_ID" "$SG_ID"
echo "Security Group ID: $SG_ID"

# Allow SSH and RDP access
aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 3389 --cidr 0.0.0.0/0

# Step 7: Launch Kali Linux EC2 Instance
echo "Launching Kali Linux EC2 Instance..."
AMI_ID="ami-xxxxxxxx"  # Replace with Kali Linux AMI ID from AWS Marketplace
INSTANCE_TYPE="t2.micro"
KEY_NAME="your-key-pair"  # Replace with your key pair name

INSTANCE_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID \
  --count 1 \
  --instance-type $INSTANCE_TYPE \
  --key-name $KEY_NAME \
  --security-group-ids $SG_ID \
  --subnet-id $SUBNET_ID \
  --associate-public-ip-address \
  --query 'Instances[0].InstanceId' --output text)

write_env "INSTANCE_ID" "$INSTANCE_ID"
echo "Instance ID: $INSTANCE_ID"

# Wait for the instance to be in 'running' state
aws ec2 wait instance-running --instance-ids $INSTANCE_ID

# Get the public IP address of the instance
PUBLIC_IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
write_env "PUBLIC_IP" "$PUBLIC_IP"
echo "Public IP Address: $PUBLIC_IP"

echo "Instance launched successfully. Public IP: $PUBLIC_IP"
