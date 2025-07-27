# Terraform Infrastructure Documentation

## Architecture Diagram
The following diagram illustrates the overall AWS infrastructure provisioned by this Terraform project:

![AWS Architecture Diagram](./assest/alb_ec2_rds.png)

This diagram shows the relationships between the VPC, subnets, route tables, security groups, EC2 webserver host multi AZ, RDS instance multi AZ, and Application load balancer providing a visual overview of the deployed resources.

This folder contains the Terraform code for provisioning a secure, highly-available AWS infrastructure, including VPC, subnets, security groups, EC2 webserver, RDS, and supporting resources. The code is modular and reusable, following best practices for infrastructure-as-code.


## Structure
### scripts/
- **bootstrap_1.sh/bootstrap_2.sh**: Contains the webserser instance user data to run at the launch of the instance in each of the AZ.

### terraform/
- **main.tf**: Orchestrates the infrastructure by calling modules for VPC, subnets, route tables, security groups, EC2, RDS and Application load balancer.
- **provider.tf**: Configures the AWS provider and required provider versions.
- **backend.tf**: Configures remote state storage in an S3 bucket for collaboration and state locking.
- **output.tf**: Exposes key outputs such as VPC ID, subnet IDs, route table IDs, EC2 instance ID, and security group IDs.
- **terraform.auto.tfvars**: Supplies actual values for input variables (e.g., environment name, DB engine, credentials).
- **variable**: Declares all input variables used across modules.
- **local.tf**: Defines local values used for cleaner expressions and consistent naming conventions.
- **source modules**: Contains reusable predefined modules for each infrastructure component from a github repo

## Usage
1. **Initialize Terraform**
   ```
   terraform init
   ```
2. **format the argument**
   ```
   terraform fmt
   ```
3. **validate the argument**
   ```
   terraform validate
   ```
4. **plan the deployment**
   ```
   terraform plan
   ```
5. **Apply the configuration**
   ```
   terraform apply
   ```

## Notes
- All sensitive credentials (RDS username/password) are stored securely in AWS SSM Parameter Store.
- Update variable values as needed in each module for your environment.
- Ensure your AWS credentials and region are configured before running Terraform.
