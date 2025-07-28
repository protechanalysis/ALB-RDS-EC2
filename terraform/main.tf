# module "object_storage" {
#   source      = "git::https://github.com/protechanalysis/terraform-aws-module.git//aws_modules/s3_bucket/vpc_flow_log_s3?ref=v1.2.1"
#   bucket_name = local.bucket
#   tags = merge(local.s3_tags, {
#     Name = "${local.name}-s3-bucket"
#   })
# }

# module "vpc" {
#   source          = "git::https://github.com/protechanalysis/terraform-aws-module.git//aws_modules/vpc?ref=v1.2.1"
#   name            = "${local.name}-vpc"
#   cidr_block      = "10.0.0.0/16"
#   log_destination = module.object_storage.vpc_flow_logs_bucket_arn
#   depends_on      = [module.object_storage]
#   tags            = local.vpc_tags
# }

# module "public_subnet" {
#   source                  = "git::https://github.com/protechanalysis/terraform-aws-module.git//aws_modules/subnets?ref=v1.2.1"
#   vpc_id                  = module.vpc.vpc_id
#   map_public_ip_on_launch = true
#   subnets                 = local.public_subnets
#   tags = merge(local.subnet_tags, {
#     Tier = "Public"
#   })
# }

# module "private_subnet" {
#   source                  = "git::https://github.com/protechanalysis/terraform-aws-module.git//aws_modules/subnets?ref=v1.2.1"
#   vpc_id                  = module.vpc.vpc_id
#   map_public_ip_on_launch = false
#   subnets                 = local.private_subnets
#   tags = merge(local.subnet_tags, {
#     Tier = "Private"
#   })
# }

# module "igw" {
#   source = "git::https://github.com/protechanalysis/terraform-aws-module.git//aws_modules/internet_gateway?ref=v1.2.1"
#   vpc_id = module.vpc.vpc_id
#   tags = merge(local.common_tags, {
#     Name = "${local.name}-vpc-igw"
#     Type = "InternetGateway"
#   })
# }

# module "nat_gateway" {
#   source           = "git::https://github.com/protechanalysis/terraform-aws-module.git//aws_modules/nat?ref=v1.2.1"
#   name             = "${local.name}-nat-gateway"
#   public_subnet_id = module.public_subnet.subnet_ids["public-1-b"]
#   tags = merge(local.common_tags, {
#     Name = "${local.name}-nat-gateway"
#     Type = "NATGateway"
#   })
# }

# module "public_route_table" {
#   source     = "git::https://github.com/protechanalysis/terraform-aws-module.git//aws_modules/routes_tables?ref=v1.2.1"
#   vpc_id     = module.vpc.vpc_id
#   name       = "public-rt"
#   type       = "public"
#   route_cidr = local.allowed_cidr_blocks
#   gateway_id = module.igw.igw_id
#   subnet_ids = module.public_subnet.subnet_ids
#   tags = merge(local.common_tags, {
#     Name = "${local.name}-public-rt"
#     Type = "Public"
#   })
# }

# module "private_route_table" {
#   source     = "git::https://github.com/protechanalysis/terraform-aws-module.git//aws_modules/routes_tables?ref=v1.2.1"
#   vpc_id     = module.vpc.vpc_id
#   name       = "private-rt"
#   type       = "private"
#   route_cidr = local.allowed_cidr_blocks
#   nat_id     = module.nat_gateway.nat_id
#   subnet_ids = module.private_subnet.subnet_ids
#   tags = merge(local.common_tags, {
#     Name = "${local.name}-private-rt"
#     Type = "Private"
#   })
# }

# module "instance_security_group" {
#   source      = "git::https://github.com/protechanalysis/terraform-aws-module.git//aws_modules/security_group?ref=v1.2.1"
#   name        = "${local.name}-instance-sg"
#   description = "Security group for EC2 instance"
#   vpc_id      = module.vpc.vpc_id
#   depends_on  = [module.alb_security_group]

#   ingress_rules = [
#     {
#       from_port                = 80
#       to_port                  = 80
#       protocol                 = "tcp"
#       source_security_group_id = module.alb_security_group.security_group_id
#       description              = "Allow traffic from ALB"
#     }
#   ]

#   egress_rules = [
#     {
#       from_port   = 0
#       to_port     = 0
#       protocol    = "-1"
#       cidr_blocks = ["0.0.0.0/0"]
#       description = "Allow all outbound"
#     }
#   ]

#   tags = merge(local.common_tags, {
#     Name = "${local.name}-instance-sg"
#     Type = "SecurityGroup"
#   })
# }


# module "database_security_group" {
#   source = "git::https://github.com/protechanalysis/terraform-aws-module.git//aws_modules/security_group?ref=v1.2.1"
#   name   = "${local.name}-database-sg"
#   description = "Security group for RDS database"
#   vpc_id = module.vpc.vpc_id
#   ingress_rules = [
#     {
#       from_port   = 3306
#       to_port     = 3306
#       protocol    = "tcp"
#       cidr_blocks = ["10.0.0.0/16"]
#       description = "Allow MySQL access from VPC"
#     }
#   ]
#   egress_rules = [
#     {
#       from_port   = 0
#       to_port     = 0
#       protocol    = "-1"
#       cidr_blocks = [local.allowed_cidr_blocks]
#       description = "Allow all outbound traffic"
#     }
#   ]
#   tags = merge(local.common_tags, {
#     Name = "${local.name}-database-sg"
#     Type = "SecurityGroup"
#   })
# }

# module "alb_security_group" {
#   source      = "git::https://github.com/protechanalysis/terraform-aws-module.git//aws_modules/security_group?ref=v1.2.1"
#   name        = "${local.name}-alb-sg"
#   description = "Security group for alb"
#   vpc_id      = module.vpc.vpc_id
#   ingress_rules = [
#     {
#       from_port   = 80
#       to_port     = 80
#       protocol    = "tcp"
#       cidr_blocks = [local.allowed_cidr_blocks]
#       description = "Allow HTTP traffic"
#     }
#   ]
#   egress_rules = [
#     {
#       from_port   = 0
#       to_port     = 0
#       protocol    = "-1"
#       cidr_blocks = [local.allowed_cidr_blocks]
#       description = "Allow all outbound traffic"
#     }
#   ]
#   tags = merge(local.common_tags, {
#     Name = "${local.name}-alb-sg"
#     Type = "SecurityGroup"
#   })
# }

# module "rds" {
#   source                 = "git::https://github.com/protechanalysis/terraform-aws-module.git//aws_modules/rds?ref=v1.2.1"
#   database_name          = "${local.name}_db"
#   password               = module.ssm_parameters.password
#   username               = module.ssm_parameters.username
#   engine                 = "mysql"
#   engine_version         = "8.0"
#   parameter_group        = "default.mysql8.0"
#   multi_az               = true
#   vpc_security_group_ids = [module.database_security_group.security_group_id]
#   subnet_id              = [module.private_subnet.subnet_ids["private-1-b"], module.private_subnet.subnet_ids["private-2-b"]]
#   tags = merge(local.rds_tags, {
#     Name = "${local.name}-rds-instance"
#   })
# }

# module "ssm_parameters" {
#   source  = "git::https://github.com/protechanalysis/terraform-aws-module.git//aws_modules/ssm_parameters?ref=v1.2.1"
#   db_host = split(":", module.rds.rds_endpoint)[0]
#   db_name = module.rds.database_name
# }

# module "role" {
#   source = "git::https://github.com/protechanalysis/terraform-aws-module.git//aws_modules/iam_role/ssm_ec2/?ref=v1.2.1"
#   name   = "${local.name}-ec2-ssm-role"
#   tags   = local.ec2_tags
# }

# module "ec2_instance_1" {
#   source                  = "git::https://github.com/protechanalysis/terraform-aws-module.git//aws_modules/instance?ref=v1.2.1"
#   instance_type           = "t3.micro"
#   vpc_id                  = module.vpc.vpc_id
#   subnet_id               = module.private_subnet.subnet_ids["private-1-a"]
#   instance_profile_name   = module.role.instance_profile_name
#   key_pair                = local.key_name
#   security_group_id       = [module.instance_security_group.security_group_id]
#   ssh_allowed_cidr_blocks = [local.allowed_cidr_blocks]
#   user_data               = file("../scripts/bootstraps_1.sh")
#   depends_on              = [module.rds]
#   tags = merge(local.ec2_tags, {
#     Name = "${local.name}-instance-1"
#   })

# }

# module "ec2_instance_2" {
#   source                  = "git::https://github.com/protechanalysis/terraform-aws-module.git//aws_modules/instance?ref=v1.2.1"
#   instance_type           = "t3.micro"
#   vpc_id                  = module.vpc.vpc_id
#   subnet_id               = module.private_subnet.subnet_ids["private-2-a"]
#   instance_profile_name   = module.role.instance_profile_name
#   key_pair                = local.key_name
#   security_group_id       = [module.instance_security_group.security_group_id]
#   ssh_allowed_cidr_blocks = [local.allowed_cidr_blocks]
#   user_data               = file("../scripts/bootstraps_2.sh")
#   depends_on              = [module.ec2_instance_1]
#   tags = merge(local.ec2_tags, {
#     Name = "${local.name}-instance-2"
#   })
# }

# module "load_balancer" {
#   source     = "git::https://github.com/protechanalysis/terraform-aws-module.git//aws_modules/load_balancer/application/?ref=v1.2.3"
#   vpc_id     = module.vpc.vpc_id
#   name       = "${local.name}-alb"
#   alb_sg_id  = [module.alb_security_group.security_group_id]
#   subnet_ids = [module.public_subnet.subnet_ids["public-1-a"], module.public_subnet.subnet_ids["public-2-a"]]
#   instance_ids = {"instance_0" = module.ec2_instance_1.instance_id 
#                   "instance_1" = module.ec2_instance_2.instance_id}
#   health_check_path = "/corp.php"
#   depends_on = [module.ec2_instance_2]
#   tags = merge(local.common_tags, {
#     Name = "${local.name}-alb"
#     Type = "ApplicationLoadBalancer"
#   })
# }