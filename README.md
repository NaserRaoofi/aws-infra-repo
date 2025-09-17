# Development Environment

A scalable, service-oriented Terraform configuration for the development environment.

## 🏗️ Architecture

```
dev/
├── main.tf                 # 🎯 Main orchestration file
├── variables.tf            # 📝 Environment variables
├── outputs.tf             # 📤 Environment outputs
├── terraform.tfvars       # ⚙️ Configuration values
├── versions.tf            # 🔒 Provider requirements
│
└── services/              # 🔧 Service modules
    ├── networking/        # 🌐 VPC, subnets, gateways
    │   ├── vpc.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── compute/           # 💻 EC2, EKS, ALB (future)
    ├── storage/           # 🗄️ RDS, S3, DynamoDB (future)
    ├── security/          # 🔒 Security Groups, IAM (future)
    └── monitoring/        # 📊 CloudWatch, alarms (future)
```

## 🚀 Quick Start

### 1. Prerequisites

Create an EC2 key pair for bastion access:

```bash
aws ec2 create-key-pair --key-name my-key-pair --query 'KeyMaterial' --output text > ~/.ssh/my-key-pair.pem
chmod 400 ~/.ssh/my-key-pair.pem
```

### 2. Deploy Infrastructure

```bash
cd /home/sirwan/terr/infra/environments/dev

# Update terraform.tfvars with your key pair name
vim terraform.tfvars  # Set bastion_key_pair_name = "your-key-pair-name"

# Deploy
terraform init
terraform plan
terraform apply
```

### 3. Access Bastion Host

After deployment:

```bash
# Get bastion public IP from outputs
terraform output bastion

# Add your SSH key to S3 bucket for access
aws s3 cp ~/.ssh/your-key.pub s3://BUCKET-NAME/public-keys/username.pub

# Connect to bastion
ssh username@BASTION-PUBLIC-IP
```

### 2. Add More Services Later

Edit `terraform.tfvars`:

```hcl
enable_compute    = true   # Enable EC2/EKS
enable_storage    = true   # Enable RDS/S3
enable_monitoring = true   # Enable CloudWatch
```

Uncomment the relevant modules in `main.tf` and run:

```bash
terraform plan
terraform apply
```

## 📋 Service Status

| Service       | Status          | Description                         |
| ------------- | --------------- | ----------------------------------- |
| 🌐 Networking | ✅ **Active**   | VPC, subnets, IGW (single AZ)       |
| � Bastion     | ✅ **Active**   | SSH bastion host for private access |
| 💻 EKS        | ✅ **Active**   | Kubernetes cluster                  |
| 🗄️ Storage    | ⏳ **Template** | RDS, S3, DynamoDB (ready to add)    |
| 🔒 Security   | ⏳ **Template** | Additional security services        |
| 📊 Monitoring | ⏳ **Template** | CloudWatch, alarms (ready to add)   |

## 🎛️ Configuration

### Current Configuration (terraform.tfvars)

```hcl
# Environment
aws_region   = "us-east-1"
project_name = "my-project"
environment  = "dev"

# Networking
vpc_cidr           = "10.0.0.0/16"
enable_nat_gateway = true
single_nat_gateway = true  # Cost optimization
enable_flow_log    = true

# Feature Flags
enable_compute    = false  # Not yet implemented
enable_storage    = false  # Not yet implemented
enable_monitoring = false  # Not yet implemented
```

## 🔗 Dependencies

### Service Dependencies

```
main.tf
  ├── networking/ (no dependencies)
  ├── compute/ (depends on: networking)
  ├── storage/ (depends on: networking)
  ├── security/ (depends on: networking)
  └── monitoring/ (depends on: all services)
```

### Outputs Flow

```
networking.vpc_id → compute.vpc_id
networking.private_subnets → compute.subnet_ids
networking.database_subnet_group → storage.subnet_group
```

## 📊 Current Resources

**Will Create (~22 resources):**

- VPC with 3 AZs
- 3 public + 3 private + 3 database subnets
- 1 Internet Gateway
- 1 NAT Gateway + Elastic IP
- Route tables and associations
- Database subnet group
- VPC Flow Logs + CloudWatch

**Cost: ~$45-50/month** (mainly NAT Gateway)

## 🎯 Benefits of This Structure

### ✅ **Scalability**

- Add services incrementally
- Clear separation of concerns
- Reusable service modules

### ✅ **Maintainability**

- Each service in its own directory
- Clear dependencies
- Consistent naming and tagging

### ✅ **Flexibility**

- Feature flags to enable/disable services
- Environment-specific configurations
- Easy to replicate for staging/prod

### ✅ **Best Practices**

- DRY principle (Don't Repeat Yourself)
- Single responsibility modules
- Infrastructure as Code standards

## 🚀 Next Steps

1. **Test Current Setup**

   ```bash
   terraform plan  # Verify configuration
   terraform apply # Deploy networking
   ```

2. **Add Compute Resources**

   - Create EC2 instances in `services/compute/`
   - Add security groups in `services/security/`
   - Enable load balancer

3. **Add Storage Resources**

   - Create RDS database in `services/storage/`
   - Add S3 buckets for application data
   - Configure backup strategies

4. **Add Monitoring**
   - CloudWatch dashboards
   - Application and infrastructure alarms
   - Log aggregation

## 🔧 Customization

### Add a New Service

1. Create directory: `services/new-service/`
2. Add module files: `variables.tf`, `main.tf`, `outputs.tf`
3. Add module call to main `main.tf`
4. Add feature flag to `variables.tf` and `terraform.tfvars`

### Change Configuration

- **Networking**: Edit `services/networking/vpc.tf`
- **Environment**: Edit `terraform.tfvars`
- **New Services**: Add to `main.tf` and create service directory
