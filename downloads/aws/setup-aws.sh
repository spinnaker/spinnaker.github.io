#!/bin/bash

check_aws_connection(){
	print_function_details
	CALLER_ARN=$(aws sts get-caller-identity | jq -r '.Arn')
	if [[ -z "$CALLER_ARN" ]]; then	
		print_error_and_exit "The aws cli does not have the propper credentials. Please fix and then try again."
	fi
}

parse_user_input(){
	print_function_details
	AWS_ACCOUNT_NAME=$(jq -r '.AWS_ACCOUNT_NAME' fill-me-out.json)
	AWS_VPC_NAME=$(jq -r '.AWS_VPC_NAME' fill-me-out.json)
	AWS_REGION=$(jq -r '.AWS_REGION' fill-me-out.json)
	MANAGING_ACCOUNT_ID=$(jq -r '.MANAGING_ACCOUNT_ID' fill-me-out.json)
	AUTH_TYPE=$(jq -r '.AUTH_TYPE' fill-me-out.json)

	if [[ -z "$MANAGING_ACCOUNT_ID" ]]
	then
		print_error_and_exit "MANAGING_ACCOUNT_ID is not set. Please fill out fill-me-out.json to with your AWS account information."
	fi

	TIMESTAMP=$(date +%s)
	SPIN_TAG="spinnaker:setup:$TIMESTAMP"
}

update_json_files(){
	print_function_details
	sed -i.bak s/MANAGING_ACCOUNT_ID/${MANAGING_ACCOUNT_ID}/g spinnaker-pass-role-policy.json
	sed -i.bak s/MANAGING_ACCOUNT_ID/${MANAGING_ACCOUNT_ID}/g spinnaker-trust-relationship.json
	sed -i.bak s/MANAGING_ACCOUNT_ID/${MANAGING_ACCOUNT_ID}/g spinnaker-assume-role-policy.json

	NUM_MANAGED_ACCOUNTS=$(jq '.MANAGED_ACCOUNT_IDS | length' fill-me-out.json)

	if [ "$NUM_MANAGED_ACCOUNTS" == "0" ]; then
		sed -i.bak s/MANAGED_ACCOUNT_ROLE_ARNS/""/g spinnaker-assume-role-policy.json
	else
		# Roles contain /. Seperator changed to #.
		MANAGED_ACCOUNT_ROLE_ARNS=$(jq '.MANAGED_ACCOUNT_IDS | map("arn:aws:iam::"+.+":role/spinnakerManaged") | join(", ")' fill-me-out.json)
		sed -i.bak s#MANAGED_ACCOUNT_ROLE_ARNS#", ${MANAGED_ACCOUNT_ROLE_ARNS}"#g spinnaker-assume-role-policy.json
	fi
}

create_vpc_and_subnet(){
	# VPC/Subnet setup pulled from https://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/vpc-subnets-commands-example.html

	print_function_details
	# Create and name VPC
	AWS_VPC_ID=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 | jq -r '.Vpc.VpcId')
	print_resource_creation $AWS_VPC_ID
	aws ec2 create-tags --resource $AWS_VPC_ID --tags Key=name,Value=$AWS_VPC_NAME
	aws ec2 create-tags --resource $AWS_VPC_ID --tags Key=name,Value=$SPIN_TAG

	# Create and name public subnet
	AWS_EXTERNAL_SUBNET_ID=$(aws ec2 create-subnet --vpc-id $AWS_VPC_ID --cidr-block 10.0.0.0/24 | jq -r '.Subnet.SubnetId')
	print_resource_creation $AWS_EXTERNAL_SUBNET_ID
	aws ec2 create-tags --resource $AWS_EXTERNAL_SUBNET_ID --tags Key=name,Value=$AWS_VPC_NAME.external.$AWS_REGION

	# Create and attach Internet Gateway 
	AWS_INTERNET_GATEWAY_ID=$(aws ec2 create-internet-gateway | jq -r '.InternetGateway.InternetGatewayId')
	print_resource_creation $AWS_INTERNET_GATEWAY_ID
	aws ec2 create-tags --resource $AWS_INTERNET_GATEWAY_ID --tags Key=name,Value=$SPIN_TAG
	aws ec2 attach-internet-gateway --vpc-id $AWS_VPC_ID --internet-gateway-id $AWS_INTERNET_GATEWAY_ID

	# Create Route Table
	AWS_ROUTE_TABLE_ID=$(aws ec2 create-route-table --vpc-id $AWS_VPC_ID | jq -r '.RouteTable.RouteTableId')
	print_resource_creation $AWS_ROUTE_TABLE_ID
	aws ec2 create-tags --resource $AWS_ROUTE_TABLE_ID --tags Key=name,Value=$SPIN_TAG

	aws ec2 create-route --route-table-id $AWS_ROUTE_TABLE_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $AWS_INTERNET_GATEWAY_ID

	# Confirm route table is active
	aws ec2 describe-route-tables --route-table-id $AWS_ROUTE_TABLE_ID
	echo "Sleeping for 30 seconds."
	sleep 30 # wait for things to propogate

	AWS_RT_ASSOCIATION_ID=$(aws ec2 associate-route-table --subnet-id $AWS_EXTERNAL_SUBNET_ID --route-table-id $AWS_ROUTE_TABLE_ID | jq -r '.AssociationId')
	print_resource_creation $AWS_RT_ASSOCIATION_ID
}

create_keypair(){
	print_function_details
	export AWS_KEYPAIR_NAME=${AWS_ACCOUNT_NAME}-${SPIN_TAG}-keypair
	aws ec2 create-key-pair --key-name $AWS_KEYPAIR_NAME | jq -r '.KeyMaterial' > ${AWS_KEYPAIR_NAME}.pem
	print_resource_creation $AWS_KEYPAIR_NAME
	chmod 400 ${AWS_KEYPAIR_NAME}.pem
}

create_policies(){
	print_function_details
	AWS_ASSUME_ROLE_POLICY_ARN=$(aws iam create-policy --policy-name SpinnakerAssumeRolePolicy --policy-document file://spinnaker-assume-role-policy.json | jq -r '.Policy.Arn')
	print_resource_creation $AWS_ASSUME_ROLE_POLICY_ARN

	AWS_PASS_ROLE_POLICY_ARN=$(aws iam create-policy --policy-name SpinnakerPassRole --policy-document file://spinnaker-pass-role-policy.json | jq -r '.Policy.Arn')
	print_resource_creation $AWS_PASS_ROLE_POLICY_ARN
}

create_launched_instance_role(){
	print_function_details
	# Create the role that instances launched/deployed with Spinnaker will assume
	AWS_BASEIAM_ROLE_ARN=$(aws iam create-role --role-name BaseIAMRole --assume-role-policy-document file://ec2-role-trust-policy.json | jq -r '.Role.Arn')
	print_resource_creation $AWS_BASEIAM_ROLE_ARN
}

create_auth_role(){
	print_function_details

	AUTH_ARN=$(aws iam create-role --role-name SpinnakerAuthRole --assume-role-policy-document file://ec2-role-trust-policy.json | jq -r '.Role.Arn')
	print_resource_creation $AUTH_ARN

	aws iam attach-role-policy --role-name SpinnakerAuthRole --policy-arn arn:aws:iam::aws:policy/PowerUserAccess 

	aws iam attach-role-policy --role-name SpinnakerAuthRole --policy-arn $AWS_ASSUME_ROLE_POLICY_ARN
}

create_auth_user(){
	print_function_details	
	echo "Creating an auth user with this script is unsupported. Please use the console to create the auth user following the documentaion at https://www.spinnaker.io/setup/install/providers/aws/#option-2-add-a-user-and-access-key--secret-pair if you haven't already."
	echo "Moving on..."

	# UNTESTED: community help requested
	# AUTH_USER_NAME=Spinnaker
	# aws iam create-user --user-name $AUTH_USER_NAME 

	# aws iam attach-user-policy --user-name $AUTH_USER_NAME --policy-arn arn:aws:iam::aws:policy/PowerUserAccess 

	# aws iam attach-user-policy --user-name $AUTH_USER_NAME --policy-arn arn:aws:iam::${MANAGING_ACCOUNT_ID}:policy/SpinnakerAssumeRolePolicy

	# AUTH_ARN=arn:aws:iam::${MANAGED_ACCOUNT_ID}:user/$AUTH_USER_NAME
	# UNTESTED: community help requested
}

create_spinnakerManaged_role(){
	print_function_details
	AWS_SPINNAKER_MANAGED_ROLE_ARN=$(aws iam create-role --role-name spinnakerManaged --assume-role-policy-document file://ec2-role-trust-policy.json | jq -r '.Role.Arn')
	print_resource_creation $AWS_SPINNAKER_MANAGED_ROLE_ARN

	echo "Sleeping for 5 seconds."
	sleep 5

	aws iam attach-role-policy --role-name spinnakerManaged --policy-arn $AWS_PASS_ROLE_POLICY_ARN

	aws iam update-assume-role-policy --role-name spinnakerManaged --policy-document file://spinnaker-trust-relationship.json
}

write_arns_to_file(){
	print_function_details
	touch aws-arns.json
	echo "{
		\"SPIN_TAG\":\"$SPIN_TAG\",
		\"AWS_VPC_ID\":\"$AWS_VPC_ID\",
		\"AWS_EXTERNAL_SUBNET_ID\":\"$AWS_EXTERNAL_SUBNET_ID\",
		\"AWS_INTERNET_GATEWAY_ID\":\"$AWS_INTERNET_GATEWAY_ID\",
		\"AWS_ROUTE_TABLE_ID\":\"$AWS_ROUTE_TABLE_ID\",
		\"AWS_RT_ASSOCIATION_ID\":\"$AWS_RT_ASSOCIATION_ID\",
		\"AWS_KEYPAIR_NAME\":\"$AWS_KEYPAIR_NAME\",
		\"AWS_BASEIAM_ROLE_ARN\":\"$AWS_BASEIAM_ROLE_ARN\",
		\"AUTH_ARN\":\"$AUTH_ARN\",
		\"AWS_ASSUME_ROLE_POLICY_ARN\":\"$AWS_ASSUME_ROLE_POLICY_ARN\",
		\"AWS_PASS_ROLE_POLICY_ARN\":\"$AWS_PASS_ROLE_POLICY_ARN\",
		\"AWS_SPINNAKER_MANAGED_ROLE_ARN\":\"$AWS_SPINNAKER_MANAGED_ROLE_ARN\"
	}" >> aws-arns.json
	echo "Created resource ARNs stored in aws-arns.json."
}

print_function_details(){
	echo "Script step: " ${FUNCNAME[1]}	
}

print_resource_creation(){
	echo "Created resource " + $1
}

print_error_and_exit(){
	ERROR_MSG=$1
	echo "Error: " $ERROR_MSG
	write_arns_to_file
	exit 1
}

check_aws_connection
parse_user_input
update_json_files
create_vpc_and_subnet
create_keypair
create_policies
create_launched_instance_role

if [[ $AUTH_TYPE == "ROLE" ]] || [[ $AUTH_TYPE == "role" ]]; then
	create_auth_role
elif [[ $AUTH_TYPE == "USER" ]] || [[ $AUTH_TYPE == "user" ]]; then
	create_auth_user
else
	print_error_and_exit "Invalid auth type. Chose ROLE or USER."
fi

create_spinnakerManaged_role
write_arns_to_file
