# Quick Reference - GitHub Actions & Terraform

##  Common Commands

### Local Development
```bash
# Format code
terraform fmt -recursive

# Initialize
terraform init

# Validate
terraform validate

# Plan
terraform plan

# Apply
terraform apply

# Destroy
terraform destroy

# Check outputs
terraform output
```

### Git Workflow
```bash
# Create feature branch
git checkout -b feature/my-feature

# Make changes and commit
git add .
git commit -m "Description of changes"

# Push to GitHub
git push origin feature/my-feature

# After PR is merged, update main
git checkout main
git pull origin main

# Delete feature branch
git branch -d feature/my-feature
```

### Checkov
```bash
# Install Checkov
pip install checkov

# Run scan
checkov -d . --framework terraform

# Run with config
checkov -d . --config-file .checkov.yml

# Output to file
checkov -d . --framework terraform -o junitxml > checkov-report.xml
```

### AWS CLI
```bash
# Configure AWS
aws configure

# List EC2 instances
aws ec2 describe-instances

# Get latest AMI ID
aws ec2 describe-images \
  --owners amazon \
  --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" \
  --query 'Images[0].ImageId' \
  --output text

# List VPCs
aws ec2 describe-vpcs

# List Key Pairs
aws ec2 describe-key-pairs
```

##  GitHub Secrets

### Required Secrets
| Secret Name | Description | Example |
|-------------|-------------|---------|
| `AWS_ACCESS_KEY_ID` | AWS Access Key | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | AWS Secret Key | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` |
| `ALLOWED_SSH_CIDR` | SSH CIDR block | `0.0.0.0/0` or `123.45.67.89/32` |
| `KEY_NAME` | EC2 Key Pair name | `my-keypair` |
| `AMI_ID` | Amazon Machine Image ID | `ami-0c55b159cbfafe1f0` |
| `INSTANCE_TYPE` | EC2 instance type | `t2.micro` |

### Adding Secrets
1. Go to repository **Settings**
2. **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Enter name and value
5. Click **Add secret**

##  Workflow Triggers

### Automatic Triggers
- **Push to main/develop**: Runs all jobs except destroy
- **Pull Request to main**: Runs scan, validate, and plan
- **Merge to main**: Runs scan, validate, and apply

### Manual Triggers
1. Go to **Actions** tab
2. Select **Terraform CI/CD with Checkov** workflow
3. Click **Run workflow**
4. Select action: `plan`, `apply`, or `destroy`
5. Click **Run workflow**

##  Workflow Jobs

| Job | When | Purpose |
|-----|------|---------|
| `security-scan` | Always (PR & Push) | Checkov security scan |
| `terraform-validate` | Always (PR & Push) | Format & validate check |
| `terraform-plan` | Pull Request only | Generate plan, comment on PR |
| `terraform-apply` | Push to main only | Deploy infrastructure |
| `terraform-destroy` | Manual trigger only | Destroy infrastructure |

##  Workflow Status

### Check Status
- Go to **Actions** tab
- View recent workflow runs
- Click on run to see detailed logs

### Download Artifacts
1. Go to workflow run
2. Scroll to **Artifacts** section
3. Download:
   - `checkov-security-report`
   - `terraform-plan`
   - `terraform-outputs`

##  Security Best Practices

###  DO
- Use GitHub Secrets for sensitive data
- Enable branch protection on `main`
- Require PR reviews before merge
- Review Terraform plans before applying
- Use least privilege IAM policies
- Enable MFA on AWS account
- Use S3 backend for state
- Regular security scans with Checkov

###  DON'T
- Commit `.tfvars` files
- Hardcode credentials in code
- Force push to `main`
- Skip PR reviews
- Ignore Checkov warnings without review
- Use admin AWS credentials
- Disable security checks

##  Troubleshooting

### Workflow Fails - Authentication Error
```bash
# Check AWS credentials
aws sts get-caller-identity

# Verify secrets in GitHub
Settings → Secrets and variables → Actions
```

### Terraform Plan Shows Unexpected Changes
```bash
# Check state file
terraform show

# Refresh state
terraform refresh

# Review differences
terraform plan -detailed-exitcode
```

### Checkov Fails
```bash
# Run locally to see issues
checkov -d . --framework terraform

# Fix issues or add exceptions in .checkov.yml
skip-check:
  - CKV_AWS_XXX
```

### Resources Not Created
```bash
# Check IAM permissions
aws iam get-user

# Verify variables
terraform console
> var.ami_id

# Check AWS service limits
aws service-quotas list-service-quotas --service-code ec2
```

##  Cost Management

### Estimate Costs
```bash
# Install Infracost
brew install infracost  # macOS
# or
curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh

# Run cost estimate
infracost breakdown --path .

# Compare with plan
terraform plan -out tfplan.binary
terraform show -json tfplan.binary > plan.json
infracost diff --path plan.json
```

### Current LAB 2 Estimated Costs
- NAT Gateway: ~$32/month + data transfer
- EC2 t2.micro (2x): Free tier or ~$17/month
- EBS volumes: ~$1-2/month
- Data transfer: Varies
**Total**: ~$50-60/month (if not using free tier)

### Cost Saving Tips
1. Use `t2.micro` for free tier
2. Destroy resources when not in use
3. Schedule auto-shutdown for non-production
4. Use Spot instances for testing
5. Monitor usage regularly

##  Useful Links

### Documentation
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [GitHub Actions](https://docs.github.com/en/actions)
- [Checkov](https://www.checkov.io/documentation)
- [AWS Free Tier](https://aws.amazon.com/free/)

### Tools
- [Terraform Cloud](https://app.terraform.io/)
- [Infracost](https://www.infracost.io/)
- [tfsec](https://aquasecurity.github.io/tfsec/)
- [Terragrunt](https://terragrunt.gruntwork.io/)

##  Support

### File Issues
1. Go to **Issues** tab
2. Click **New issue**
3. Choose template (Bug or Feature)
4. Fill in details
5. Submit

### Get Help
- Review [SETUP_GUIDE.md](SETUP_GUIDE.md)
- Check [CHECKLIST.md](CHECKLIST.md)
- Review workflow logs
- Check AWS documentation

##  Learning Resources

- [Terraform Tutorial](https://learn.hashicorp.com/terraform)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [GitHub Actions Tutorial](https://docs.github.com/en/actions/learn-github-actions)
- [Infrastructure as Code Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
