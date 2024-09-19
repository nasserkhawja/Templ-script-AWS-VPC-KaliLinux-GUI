Templ-script-AWS-VPC-KaliLinux-GUI

Creates the VPC, Subnet, Internet Gateway, Security Group, and EC2 instance and stores their IDs in a file.
User Data: Automates the installation of the GUI and xRDP (or VNC) on Kali Linux upon instance launch.
Environment File: Stores the required IDs and information for reuse during subsequent steps.
Cleanup Script: Terminates the instance and deletes AWS resources after usage.
VPC, EC2 instance, and installing the GUI on Kali Linux while storing values such as VPC ID, Subnet ID, and others in a sourceable file. Env for pentestting, vulnerability scanning/assessment 

Script to Set Up VPC and EC2 Instance
You can store variables like VPC ID, Subnet ID, etc., in a file (e.g., aws_kali_env_vars.sh) and source the file whenever needed.

GUI Installation (Kali Linux)
After the EC2 instance is up, run the installation of the GUI and remote desktop tools using User Data. When Pass the following commands as user data, which will run automatically after the instance is started.

Source below file to echo environment settings. Ensure file security paramaters in place.
source aws_kali_env_vars.sh

echo "Using VPC ID: $VPC_ID"
echo "Using Subnet ID: $SUBNET_ID"


