# 📂 Project Structure

## Complete File Tree

```
LAB_2/
│
├── 📄 main.tf                          # Root module - orchestrates all modules
├── 📄 variables.tf                     # Input variables definitions
├── 📄 outputs.tf                       # Output values
├── 📄 providers.tf                     # Terraform & AWS provider config
├── 📄 terraform.tfvars.example         # Example variables file
├── 📄 terraform.tfvars                 # Actual variables (DO NOT COMMIT)
│
├── 📁 modules/                         # Terraform modules
│   ├── 📁 vpc/                         # VPC module
│   │   ├── 📄 main.tf                  # VPC, Subnets, IGW, NAT, Routes
│   │   ├── 📄 variables.tf             # Module variables
│   │   └── 📄 outputs.tf               # Module outputs
│   │
│   ├── 📁 security_groups/             # Security Groups module
│   │   ├── 📄 main.tf                  # Security group definitions
│   │   ├── 📄 variables.tf             # Module variables
│   │   └── 📄 outputs.tf               # Module outputs
│   │
│   └── 📁 ec2/                         # EC2 module
│       ├── 📄 main.tf                  # EC2 instance definitions
│       ├── 📄 variables.tf             # Module variables
│       └── 📄 outputs.tf               # Module outputs
│
├── 📁 .github/                         # GitHub configuration
│   ├── 📁 workflows/                   # GitHub Actions workflows
│   │   └── 📄 terraform.yml            # Main CI/CD workflow
│   │
│   ├── 📁 ISSUE_TEMPLATE/              # Issue templates
│   │   ├── 📄 bug_report.md            # Bug report template
│   │   └── 📄 feature_request.md       # Feature request template
│   │
│   └── 📄 pull_request_template.md     # PR template
│
├── 📄 .checkov.yml                     # Checkov configuration
├── 📄 .gitignore                       # Git ignore rules
├── 📄 .pre-commit-config.yaml          # Pre-commit hooks config
├── 📄 Makefile                         # Common commands
│
├── 📄 README.md                        # Main project documentation
├── 📄 SETUP_GUIDE.md                   # Detailed setup instructions
├── 📄 GITHUB_ACTIONS_README.md         # Workflow documentation
├── 📄 CHECKLIST.md                     # Implementation checklist
├── 📄 QUICK_REFERENCE.md               # Command reference
├── 📄 ARCHITECTURE.md                  # Architecture diagrams
├── 📄 DELIVERABLES.md                  # Project deliverables summary
├── 📄 PROJECT_STRUCTURE.md             # This file
│
└── 📜 setup-verify.ps1                 # Setup verification script
```

## File Descriptions

### 🔧 Core Terraform Files

#### `main.tf`
- **Purpose**: Root module that ties everything together
- **Content**: Calls to VPC, Security Groups, and EC2 modules
- **Dependencies**: modules/vpc, modules/security_groups, modules/ec2

#### `variables.tf`
- **Purpose**: Defines input variables for the project
- **Variables**:
  - `aws_region` - AWS region (default: us-east-1)
  - `aws_profile` - AWS CLI profile
  - `allowed_ssh_cidr` - SSH access CIDR
  - `key_name` - EC2 key pair name
  - `ami_id` - Amazon Machine Image ID
  - `instance_type` - EC2 instance type

#### `outputs.tf`
- **Purpose**: Defines output values after deployment
- **Outputs**: VPC ID, EC2 IPs, etc.

#### `providers.tf`
- **Purpose**: Terraform and provider configuration
- **Content**: Terraform version, AWS provider setup

#### `terraform.tfvars` / `terraform.tfvars.example`
- **Purpose**: Variable values
- **Note**: `.tfvars` should NOT be committed (in .gitignore)
- **Example**: `.example` file shows format

### 📦 Modules

#### `modules/vpc/`
**Files**: main.tf, variables.tf, outputs.tf
**Creates**:
- VPC (10.0.0.0/16)
- Public Subnet (10.0.1.0/24)
- Private Subnet (10.0.2.0/24)
- Internet Gateway
- NAT Gateway
- Route Tables (Public + Private)
- Route Table Associations

**Outputs**:
- `vpc_id` - VPC ID
- `public_subnet_id` - Public subnet ID
- `private_subnet_id` - Private subnet ID

#### `modules/security_groups/`
**Files**: main.tf, variables.tf, outputs.tf
**Creates**:
- Public Security Group (SSH, HTTP)
- Private Security Group (SSH from Public SG)

**Inputs**:
- `vpc_id` - VPC to create SGs in
- `allowed_ssh_cidr` - CIDR for SSH access

**Outputs**:
- `public_sg_id` - Public SG ID
- `private_sg_id` - Private SG ID

#### `modules/ec2/`
**Files**: main.tf, variables.tf, outputs.tf
**Creates**:
- Public EC2 Instance
- Private EC2 Instance

**Inputs**:
- `public_subnet_id` - Subnet for public instance
- `private_subnet_id` - Subnet for private instance
- `public_sg_id` - Security group for public instance
- `private_sg_id` - Security group for private instance
- `ami_id` - AMI for instances
- `instance_type` - Instance type
- `key_name` - Key pair name

**Outputs**:
- Instance IDs and IP addresses

### ⚙️ GitHub Actions

#### `.github/workflows/terraform.yml`
**Purpose**: Main CI/CD workflow
**Triggers**:
- Push to main/develop
- Pull Request to main
- Manual (workflow_dispatch)

**Jobs**:
1. **security-scan**: Checkov security scanning
2. **terraform-validate**: Format & validation checks
3. **terraform-plan**: Generate plan (PR only)
4. **terraform-apply**: Deploy (main branch only)
5. **terraform-destroy**: Destroy (manual only)

**Features**:
- AWS credentials from secrets
- Artifact uploads
- PR comments
- Environment protection

#### `.github/pull_request_template.md`
**Purpose**: Template for pull requests
**Sections**:
- Description
- Type of change
- Checklist
- Terraform plan output
- Checkov results
- Resources impact

#### `.github/ISSUE_TEMPLATE/`
**Purpose**: Templates for issues
**Types**:
- `bug_report.md` - For reporting bugs
- `feature_request.md` - For requesting features

### 🔒 Security & Configuration

#### `.checkov.yml`
**Purpose**: Checkov configuration
**Settings**:
- Frameworks to scan
- Output formats
- Skip rules (if needed)
- Specific checks to run

#### `.gitignore`
**Purpose**: Files to exclude from Git
**Excludes**:
- `.terraform/` directory
- `*.tfstate` files
- `*.tfvars` files (sensitive)
- `.pem` / `.key` files
- IDE settings
- OS files

#### `.pre-commit-config.yaml`
**Purpose**: Pre-commit hooks configuration
**Hooks**:
- Terraform format
- Terraform validate
- Terraform docs
- Checkov scan
- Secret detection
- General file checks

### 📚 Documentation

#### `README.md`
**Purpose**: Main project documentation
**Sections**:
- Project overview
- Features
- Architecture
- Quick start
- Workflow
- Monitoring
- Cleanup

#### `SETUP_GUIDE.md`
**Purpose**: Complete setup walkthrough
**Sections**:
- Prerequisites
- Step-by-step setup
- GitHub secrets configuration
- Environment setup
- Testing
- Troubleshooting

#### `GITHUB_ACTIONS_README.md`
**Purpose**: Workflow documentation
**Sections**:
- Jobs description
- Required secrets
- Usage guide
- Environments
- Backend configuration

#### `CHECKLIST.md`
**Purpose**: Implementation checklist
**Sections**:
- Phase-by-phase tasks
- Deliverables tracking
- Scoring rubric
- Common pitfalls

#### `QUICK_REFERENCE.md`
**Purpose**: Command reference
**Sections**:
- Common commands
- GitHub secrets
- Workflow triggers
- Troubleshooting

#### `ARCHITECTURE.md`
**Purpose**: Architecture documentation
**Sections**:
- Network topology
- Resource details
- CI/CD pipeline
- Security architecture
- Data flow diagrams

#### `DELIVERABLES.md`
**Purpose**: Project deliverables summary
**Sections**:
- Requirements checklist
- Files created
- Features implemented
- Expected results

### 🛠️ Utility Files

#### `Makefile`
**Purpose**: Common command shortcuts
**Commands**:
```bash
make init       # Initialize Terraform
make fmt        # Format code
make validate   # Validate configuration
make plan       # Generate plan
make apply      # Apply changes
make destroy    # Destroy resources
make checkov    # Run security scan
make test       # Run all checks
```

#### `setup-verify.ps1`
**Purpose**: Automated setup verification
**Checks**:
- Required tools installed
- AWS credentials configured
- Project files present
- Terraform validation
- Git repository status

## File Dependencies

```
main.tf
  ├─ modules/vpc
  │   └─ outputs → VPC ID, Subnet IDs
  │
  ├─ modules/security_groups
  │   ├─ inputs ← VPC ID
  │   └─ outputs → Security Group IDs
  │
  └─ modules/ec2
      ├─ inputs ← Subnet IDs, SG IDs
      └─ outputs → Instance IDs, IPs

variables.tf
  └─ provides variables to → main.tf

terraform.tfvars
  └─ provides values to → variables.tf

.github/workflows/terraform.yml
  ├─ uses → Terraform files
  ├─ uses → .checkov.yml
  └─ creates → Artifacts
```

## Important Notes

### ✅ Files to Commit
- All `.tf` files
- All documentation (`.md`)
- Workflow files (`.github/`)
- Configuration files (`.checkov.yml`, `.gitignore`)
- Templates and examples

### ❌ Files NOT to Commit
- `terraform.tfvars` (contains sensitive data)
- `*.tfstate` (state files)
- `.terraform/` (provider plugins)
- `*.pem`, `*.key` (SSH keys)
- IDE-specific files

### 🔐 Sensitive Information
Never commit:
- AWS credentials
- Access keys
- SSH private keys
- Sensitive variable values

Use:
- GitHub Secrets for CI/CD
- `.tfvars` for local (in .gitignore)
- Environment variables

## File Size Summary

### Terraform Files
- **Total Lines**: ~500-800 lines
- **Core files**: ~100 lines
- **Module files**: ~400-700 lines

### Documentation
- **Total**: ~3000+ lines
- **Setup guides**: ~1500 lines
- **Reference docs**: ~1500 lines

### Workflow
- **terraform.yml**: ~280 lines
- **Complete automation**: Plan, Apply, Destroy

## Usage Flow

1. **Development**
   ```
   Edit .tf files → Run make fmt → Run make validate → Commit
   ```

2. **Local Testing**
   ```
   make init → make plan → make apply → make destroy
   ```

3. **GitHub Workflow**
   ```
   Create PR → Workflow runs → Review plan → Merge → Auto-deploy
   ```

4. **Verification**
   ```
   ./setup-verify.ps1 → Check all requirements
   ```

## Quick File Access

### Need to...
- **Setup project**: Read `SETUP_GUIDE.md`
- **Quick commands**: Check `QUICK_REFERENCE.md`
- **Understand workflow**: Read `GITHUB_ACTIONS_README.md`
- **Track progress**: Use `CHECKLIST.md`
- **See architecture**: View `ARCHITECTURE.md`
- **Verify setup**: Run `setup-verify.ps1`
- **Run commands**: Use `Makefile`

---

**Total Files Created**: 25+ files
**Total Documentation**: 7 comprehensive guides
**Total Lines of Code/Docs**: 4000+ lines

All files work together to provide:
✅ Complete Infrastructure as Code
✅ Full CI/CD Automation
✅ Security Scanning
✅ Comprehensive Documentation
