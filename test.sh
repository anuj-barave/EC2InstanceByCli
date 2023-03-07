#!/bin/sh
#Configuring IAM User Profile
echo "Let's configure AWS profile";
echo "Enter User profile Name";
read profile;
echo " Enter AWS Access Key ID : ";
read aws_id;
echo " Enter AWS Secret Access Key : ";
read aws_secret_key;
echo "Enter default Region Name e.g(ap-south-1)"
read region;
echo "___________________Configuration Completed !___________________"
aws configure set aws_access_key_id $aws_id && aws configure set aws_secret_access_key $aws_secret_key && aws configure set region $region
#Creating Profile
# Create Public subnet_id
echo "______________________________________________________________"
echo "Available VPC's"
aws ec2 describe-vpcs --query 'Vpcs[*].[VpcId,CidrBlock]'
echo "______________________________________________________________"
#Input from user in which VPC he want to create a Subnet
echo "Enter The VPC ID";
read vpc_id;
#user will enter the required CIDR block value
echo "Enter CIDR block ";
read cidr;
aws ec2 create-subnet --vpc-id $vpc_id --cidr-block $cidr
echo "____________________Subnet Created !! _______________________"
echo "______________________________________________________________"
echo " Available Route Table's"
aws ec2 describe-route-tables --query 'RouteTables[*].[RouteTableId]'
echo "______________________________________________________________"
echo "enter Route Table ID of your VPC";
read route_id;
echo "Enter subnet ID of the Created subnet ";
read modify_subnet
#Attaching subnet to required routable
aws ec2 associate-route-table --subnet-id $modify_subnet --route-table-id $route_id
echo "_________________ Route associated !! _________________________"
#Enabling Public-ip on launch for the created subnet
aws ec2 modify-subnet-attribute --subnet-id $modify_subnet --map-public-ip-on-launch
echo "____________________ Modified Subnet !! _________________________"
# creating Security Group
aws ec2 create-security-group --group-name "oea-sec-grp-1" --description "this is a sample security group with open ports http,ssh" --vpc-id $vpc_id
echo "_____________________Security group Created !!______________________"
echo "Enter Security ID Created Above "
read sec_grp_id
#Giving SSH and HTTP as inbound access to the created security group
aws ec2 authorize-security-group-ingress --group-id $sec_grp_id --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $sec_grp_id --protocol tcp --port 80 --cidr 0.0.0.0/0
echo " Launching EC2 Instance ..."
echo "Create Ec2 Instance through CLI \n";
echo "Enter Machine Image ID (ami)";
read ami;
echo "Enter No of Instances :";
read count;
echo "Enter Instances Type : ";
read instance_type;
echo "Enter Key pair Name : ";
read key_pair;
aws ec2 run-instances --image-id $ami --count $count --instance-type $instance_type --key-name $key_pair --security-group-ids $sec_grp_id --subnet-id $modify_subnet > result.txt
echo "_______________________VM Launched !! _______________"
cat result.txt
echo "______________________________________________________________\n"
aws ec2 describe-instances \
--query "Reservations[*].Instances[*].PublicIpAddress" \
--output=text
echo "______________________________________________________________"
echo "Connecting to Instance via ssh ..."
echo "Enter public IP ";
read public_ip
ssh -i $key_pair.pem ec2-user@$public_ip -yes

