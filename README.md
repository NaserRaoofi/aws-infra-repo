# Development Environment

A scalable, service-oriented Terraform configuration for the development environment with EKS cluster and ALB controller support.

## 🏗️ Architecture

```
dev/
├── main.tf                 # 🎯 Main orchestration file
├── variables.tf            # 📝 Environment variables
├── outputs.tf             # 📤 Environment outputs
├── terraform.tfvars       # ⚙️ Configuration values
├── .gitignore             # � Git ignore for Terraform artifacts
│
└── services/              # 🔧 Service modules
    ├── networking/        # 🌐 VPC, subnets, gateways, security groups
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── compute/           # 💻 EKS cluster with managed node groups
    │   └── eks/
    │       ├── main.tf
    │       ├── variables.tf
    │       └── output.tf
    ├── security/          # 🔒 IAM roles, policies, security groups
    │   ├── iam-roles/
    │   │   ├── alb-controller-role.tf
    │   │   ├── variables.tf
    │   │   ├── outputs.tf
    │   │   └── policy/
    │   │       └── alb-controller-policy.json
    │   ├── main.tf
    │   ├── sg.tf
    │   └── nacl.tf
    ├── storage/           # 🗄️ RDS, S3, DynamoDB (future)
    └── monitoring/        # 📊 CloudWatch, alarms (future)
```

## 🚀 Quick Start

### 1. Prerequisites

Ensure you have:

- AWS CLI configured with appropriate permissions
- Terraform installed (>= 1.0)
- kubectl installed for EKS cluster access

### 2. Deploy Infrastructure

```bash
cd /home/sirwan/aws-infra-repo/aws-infra/environments/dev

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Deploy infrastructure
terraform apply
```

### 3. Access EKS Cluster

After deployment:

```bash
# Update kubeconfig for EKS cluster access
aws eks update-kubeconfig --region us-east-1 --name my-project-dev-eks

# Verify cluster access
kubectl get nodes

# Get cluster information
kubectl cluster-info
```

### 4. Deploy ALB Controller (Optional)

The infrastructure includes IAM role for ALB controller. To deploy:

```bash
# Install ALB controller using Helm
helm repo add eks https://aws.github.io/eks-charts
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=my-project-dev-eks \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=us-east-1 \
  --set vpcId=$(terraform output -raw vpc_id)
```

## 📋 Service Status

| Service           | Status          | Description                                          |
| ----------------- | --------------- | ---------------------------------------------------- |
| 🌐 Networking     | ✅ **Active**   | VPC, subnets, IGW, NAT Gateway, security groups      |
| 💻 EKS            | ✅ **Active**   | Kubernetes cluster with 3 managed node groups        |
| � Security        | ✅ **Active**   | IAM roles, ALB controller policy, security groups    |
| 🏗️ ALB Controller | ✅ **Active**   | IAM role and policy for AWS Load Balancer Controller |
| 🗄️ Storage        | ⏳ **Template** | RDS, S3, DynamoDB (ready to add)                     |
| 📊 Monitoring     | ⏳ **Template** | CloudWatch, alarms (ready to add)                    |

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

# EKS Configuration
cluster_version = "1.33"
cluster_endpoint_public_access  = true
cluster_endpoint_private_access = true

# Node Groups
eks_node_groups = {
  system = {
    instance_types = ["t3.medium"]
    capacity_type  = "ON_DEMAND"
    min_size      = 1
    max_size      = 3
    desired_size  = 2
  }
  general = {
    instance_types = ["t3.large"]
    capacity_type  = "SPOT"
    min_size      = 0
    max_size      = 10
    desired_size  = 2
  }
  database = {
    instance_types = ["r5.large"]
    capacity_type  = "ON_DEMAND"
    min_size      = 0
    max_size      = 5
    desired_size  = 1
  }
}

# ALB Controller
enable_alb_controller = true
```

## 🔗 Dependencies

### Service Dependencies

```
main.tf
  ├── networking/ (no dependencies)
  ├── compute/eks/ (depends on: networking)
  ├── security/iam-roles/ (depends on: compute/eks)
  ├── storage/ (depends on: networking)
  └── monitoring/ (depends on: all services)
```

### Outputs Flow

```
networking.vpc_id → compute/eks.vpc_id
networking.private_subnets → compute/eks.subnet_ids
networking.vpc_id → security/iam-roles.vpc_id
compute/eks.oidc_provider_arn → security/iam-roles.oidc_provider_arn
security/iam-roles.alb_controller_role_arn → compute/eks.alb_controller_role_arn
```

## 📊 Current Resources

**Active Resources (~85+ resources):**

### Networking

- VPC with 2 AZs (us-east-1a, us-east-1b)
- 2 public + 2 private subnets
- 1 Internet Gateway
- 1 NAT Gateway + Elastic IP
- Route tables and associations
- Security groups for EKS and VPC endpoints
- VPC endpoints (EC2, ECR, EKS, S3)

### EKS Cluster

- EKS cluster v1.33 with public/private API access
- 3 managed node groups (system, general, database)
- OIDC provider for service account authentication
- EKS addons: CoreDNS, kube-proxy, VPC CNI, EBS CSI driver
- KMS key for encryption

### Security & IAM

- IAM role and policy for ALB controller
- Service account for AWS Load Balancer Controller
- Security groups with proper ingress/egress rules
- OIDC trust relationships

**Estimated Cost: ~$150-200/month**

- EKS cluster: ~$72/month
- Node groups: ~$50-100/month (depending on usage)
- NAT Gateway: ~$45/month
- Other resources: ~$20-30/month

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

1. **Deploy ALB Controller**

   ```bash
   # Install ALB controller service account and deployment
   kubectl apply -f https://github.com/kubernetes-sigs/aws-load-balancer-controller/releases/download/v2.4.7/v2_4_7_full.yaml

   # Annotate service account with IAM role
   kubectl annotate serviceaccount aws-load-balancer-controller \
     -n kube-system \
     eks.amazonaws.com/role-arn=$(terraform output -raw alb_controller_role_arn)
   ```

2. **Deploy Applications**

   - Create Kubernetes deployments and services
   - Use Ingress resources with ALB annotations
   - Configure SSL certificates with ACM

3. **Add Storage Resources**

   - Create RDS database in `services/storage/`
   - Add S3 buckets for application data
   - Configure EBS storage classes

4. **Add Monitoring**
   - CloudWatch Container Insights
   - Application and infrastructure alarms
   - Log aggregation with Fluent Bit

## 🔧 ALB Controller Setup

The infrastructure includes a pre-configured IAM role for the AWS Load Balancer Controller with all required permissions:

### Included Permissions

- `elasticloadbalancing:*` (describe, create, modify, delete)
- `ec2:DescribeRouteTables`
- `ec2:DescribeSecurityGroups`
- `ec2:DescribeSubnets`
- `ec2:DescribeVpcs`
- `iam:CreateServiceLinkedRole`
- And many more...

### Service Account Configuration

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: aws-load-balancer-controller
  namespace: kube-system
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::ACCOUNT:role/dev-my-project-alb-controller-role
```

## 🔧 Customization

### Add a New Service

1. Create directory: `services/new-service/`
2. Add module files: `variables.tf`, `main.tf`, `outputs.tf`
3. Add module call to main `main.tf`
4. Update dependencies and outputs

### Modify EKS Configuration

- **Node Groups**: Edit `terraform.tfvars` node group configuration
- **Cluster Version**: Update `cluster_version` in `terraform.tfvars`
- **API Access**: Modify `cluster_endpoint_*_access` variables

### Update ALB Controller Permissions

- **Policy**: Edit `services/security/iam-roles/policy/alb-controller-policy.json`
- **Apply**: Run `terraform apply` to update the policy in AWS

### Change Networking

- **VPC CIDR**: Edit `vpc_cidr` in `terraform.tfvars`
- **Subnets**: Modify subnet configuration in `services/networking/main.tf`
- **Security Groups**: Update rules in `services/security/sg.tf`

## 🛠️ Troubleshooting

### Common Issues

1. **ALB Controller Permission Errors**

   - Check if all required permissions are in the policy
   - Verify OIDC provider is correctly configured
   - Ensure service account annotation matches IAM role ARN

2. **EKS Node Group Issues**

   - Verify subnet tags for load balancer discovery
   - Check security group rules for node communication
   - Ensure IAM roles have required policies attached

3. **Networking Issues**
   - Verify route table configurations
   - Check NAT Gateway and Internet Gateway
   - Ensure security groups allow required traffic

### Useful Commands

```bash
# Check EKS cluster status
aws eks describe-cluster --name my-project-dev-eks

# Get node group information
aws eks describe-nodegroup --cluster-name my-project-dev-eks --nodegroup-name system

# Verify ALB controller logs
kubectl logs -n kube-system deployment/aws-load-balancer-controller

# Check terraform state
terraform state list
terraform show
```

## 📚 Additional Resources

- [AWS Load Balancer Controller Documentation](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)
- [EKS Best Practices Guide](https://aws.github.io/aws-eks-best-practices/)
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
