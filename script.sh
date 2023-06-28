#!/bin/bash

# Function to check if AWS CLI is installed and install it if necessary
check_install_aws_cli() {
    if ! command -v aws &> /dev/null; then
        echo "AWS CLI is not installed. Installing..."
        # Install AWS CLI
        sudo apt install awscli
    else
        echo "AWS CLI is already installed."
    fi
}

# Function to check if Terraform is installed and install it if necessary
check_install_terraform() {
    if ! command -v terraform &> /dev/null; then
        echo "Terraform is not installed. Installing..."
        # Install Terraform
        sudo apt-get update && sudo apt-get install -y gnupg software-properties-common

        wget -O- https://apt.releases.hashicorp.com/gpg | \
        gpg --dearmor | \
        sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg

        gpg --no-default-keyring \
        --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
        --fingerprint

        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
        https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
        sudo tee /etc/apt/sources.list.d/hashicorp.list

        sudo apt update

        sudo apt-get install terraform
    else
        echo "Terraform is already installed."
    fi
}

# Function to configure AWS credentials
configure_aws_credentials() {
    echo " "
    echo "=== AWS Configuration ==="
    echo "Please enter your AWS access key ID, secret access key, default region, and output format."
    echo "Leave the fields blank and press Enter to keep existing configurations."

    # Configure AWS credentials
    aws configure
}

# Function to download the required plugins and execute Terraform commands
execute_terraform() {
    echo " "
    echo "=== Terraform ==="

    echo "Downloading required plugins..."
    terraform init

    echo " "
    echo "Running Terraform plan..."
    terraform plan

    echo " "
    echo "Applying Terraform changes..."
    terraform apply
}

# Main script
pushd ~
check_install_aws_cli
check_install_terraform
configure_aws_credentials
popd # Return to previous directory


echo " "
read -p "Executing  terraform will create the resources on your aws account
as per configured in main.tf file. Do you want to execute terraform ? (yes/no) " execute_terraform_prompt
if [[ "$execute_terraform_prompt" =~ ^[Yy][Ee][Ss]$ ]]; then
    execute_terraform
else
    echo "Exiting..."
    exit 0
fi
