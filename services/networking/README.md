# Networking Service Configuration

This networking service uses **JSON-based configuration** for Network ACLs and Security Groups, providing clean separation of configuration from infrastructure code.

## 🎯 JSON Configuration Approach

All NACL rules are defined in JSON configuration files, providing:

- ✅ Clean separation of configuration from implementation
- ✅ Environment-specific rule sets
- ✅ Version-controlled rule management
- ✅ Easy integration with CI/CD pipelines
- ✅ Dynamic VPC CIDR replacement

## 📁 File Structure

```
services/networking/
├── main.tf                           # Infrastructure code (clean & minimal)
├── locals.tf                         # JSON processing logic
├── variables.tf                      # Basic variables only
├── config/
│   ├── nacl-rules.json              # Default/Dev NACL rules
│   ├── staging-nacl-rules.json      # Staging environment rules
│   └── prod-nacl-rules.json         # Production environment rules
└── README.md                        # This file
```

## 🔧 Configuration Files

### Default Configuration (nacl-rules.json)

Used for development environment with permissive SSH access.

### Environment-Specific Configurations

- **staging-nacl-rules.json**: SSH restricted to private networks
- **prod-nacl-rules.json**: SSH highly restricted to admin network only

## 📝 Usage

### Using Different Environments

To use environment-specific rules, modify `locals.tf`:

```hcl
# For staging
nacl_config = jsondecode(file("${path.module}/config/staging-nacl-rules.json"))

# For production
nacl_config = jsondecode(file("${path.module}/config/prod-nacl-rules.json"))
```

### Adding Custom Rules

1. Edit the appropriate JSON file in `config/`
2. Add new rule to the relevant section:

```json
{
  "rule_number": 150,
  "rule_action": "allow",
  "from_port": 8080,
  "to_port": 8080,
  "protocol": "tcp",
  "cidr_block": "10.0.0.0/16",
  "description": "Allow custom application port"
}
```

3. Rules are automatically applied on next `terraform apply`

## 🛡️ Security Features

### Network ACLs

- **Default NACL**: VPC-only traffic (locked down)
- **Public NACL**: HTTP/HTTPS/SSH + ephemeral ports
- **Private NACL**: VPC traffic + HTTPS for endpoints

### Security Groups

- **Default SG**: Completely locked down (no rules)
- **ALB SG**: HTTP/HTTPS from internet
- **EKS Nodes SG**: ALB + VPC traffic
- **Bastion SG**: SSH from trusted IPs
- **Database SG**: DB ports from EKS nodes + bastion

## 🔄 Dynamic Features

### VPC CIDR Replacement

Use `"VPC_CIDR"` as a placeholder in JSON files:

```json
{
  "cidr_block": "VPC_CIDR",
  "description": "Allow all traffic from VPC"
}
```

This gets automatically replaced with the actual VPC CIDR block.

### Environment-Specific SSH Access

- **Dev**: `0.0.0.0/0` (open for development)
- **Staging**: `10.0.0.0/8` (private networks only)
- **Prod**: `192.168.1.0/24` (specific admin network)

## 📊 Benefits

✅ **Clean Code**: Infrastructure code is minimal and focused
✅ **Maintainable**: Rules separated from Terraform code
✅ **Flexible**: Easy to switch between environment rule sets
✅ **Secure**: Environment-specific security policies
✅ **Version Controlled**: JSON files tracked in git
✅ **CI/CD Ready**: Easy to integrate with automated deployments

## 🚀 Getting Started

1. Choose your environment configuration file
2. Customize rules in the JSON file as needed
3. Update `locals.tf` to point to your desired config
4. Run `terraform plan` to see changes
5. Run `terraform apply` to deploy

The JSON approach provides maximum flexibility while keeping your Terraform code clean and maintainable!
