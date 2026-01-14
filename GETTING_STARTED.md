# 🚀 Getting Started - LAB 2

> **Quick start guide để triển khai LAB 2 trong 30 phút**

## 📋 Prerequisites (5 phút)

### Required Tools
- [ ] Terraform >= 1.3.0
- [ ] AWS CLI configured
- [ ] Git installed
- [ ] GitHub account
- [ ] Python 3.x (for Checkov)

### Verify Installation
```powershell
# Run verification script
./setup-verify.ps1
```

## ⚡ Quick Setup (10 phút)

### Step 1: Create GitHub Repository
```bash
# Initialize Git if not already done
git init

# Add files
git add .
git commit -m "Initial LAB 2 setup with Terraform and GitHub Actions"

# Create repo on GitHub and push
git remote add origin https://github.com/YOUR_USERNAME/LAB_2.git
git branch -M main
git push -u origin main
```

### Step 2: Configure GitHub Secrets
Go to: **Repository → Settings → Secrets and variables → Actions**

Add these secrets:
```
AWS_ACCESS_KEY_ID          = <your-aws-access-key>
AWS_SECRET_ACCESS_KEY      = <your-aws-secret-key>
ALLOWED_SSH_CIDR           = 0.0.0.0/0  (or your IP)
KEY_NAME                   = <your-ec2-keypair-name>
AMI_ID                     = ami-0c55b159cbfafe1f0  (or your region AMI)
INSTANCE_TYPE              = t2.micro
```

**Get AMI ID for your region:**
```bash
aws ec2 describe-images \
  --owners amazon \
  --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" \
  --query 'Images[0].ImageId' \
  --output text
```

### Step 3: (Optional) Configure Environments
Go to: **Settings → Environments**

Create:
1. **production**
   - Required reviewers: yourself
   - Deployment branches: main only

2. **production-destroy**
   - Required reviewers: yourself
   - For destroy operations

## 🧪 Test Workflow (10 phút)

### Test 1: Create PR to test security scan
```bash
# Create test branch
git checkout -b test/security-scan

# Make a small change
echo "# Test" >> main.tf

# Push and create PR
git add .
git commit -m "Test: Security scan workflow"
git push origin test/security-scan
```

Then:
1. Go to GitHub and create Pull Request
2. Watch workflow run in Actions tab
3. Check PR comments for Checkov results
4. Review security report in artifacts

### Test 2: Deploy to AWS
```bash
# After PR is approved, merge it
# Or create a new change on main directly

git checkout main
git pull

# Make a change
echo "# Deployed" >> main.tf

git add .
git commit -m "Deploy infrastructure"
git push origin main
```

Then:
1. Go to Actions tab
2. Watch workflow run
3. Approve deployment if environment protection is enabled
4. Verify resources in AWS Console

## ✅ Verification (5 phút)

### Check GitHub Actions
- [ ] Go to Actions tab
- [ ] Verify all workflows passed
- [ ] Download artifacts (security reports, plans, outputs)

### Check AWS Console
Go to AWS Console and verify:
- [ ] VPC created (10.0.0.0/16)
- [ ] 2 Subnets (public & private)
- [ ] Internet Gateway attached
- [ ] NAT Gateway in public subnet
- [ ] 2 Route Tables configured
- [ ] 2 Security Groups created
- [ ] 2 EC2 Instances running

### Test Infrastructure
```bash
# Get public IP from outputs
terraform output

# Or from AWS CLI
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=public-instance" \
  --query 'Reservations[0].Instances[0].PublicIpAddress'

# SSH to public instance (if you have the key)
ssh -i your-key.pem ec2-user@<public-ip>
```

## 📊 What You Get

### Automated Workflows
✅ **Security Scanning**: Every push and PR
✅ **Code Validation**: Automatic format and validate
✅ **PR Planning**: See changes before merge
✅ **Auto Deployment**: Deploy on merge to main
✅ **Manual Control**: Trigger plan/apply/destroy manually

### Infrastructure
✅ **Complete VPC**: With public and private subnets
✅ **High Availability**: NAT Gateway for private instances
✅ **Security**: Properly configured Security Groups
✅ **Compute**: 2 EC2 instances (public & private)

### Documentation
✅ **7 Comprehensive Guides**: Setup, reference, architecture, etc.
✅ **Templates**: PR and issue templates
✅ **Scripts**: Automated verification
✅ **Examples**: Configuration examples

## 🎯 Common Tasks

### Make Infrastructure Changes
```bash
# 1. Create feature branch
git checkout -b feature/add-instances

# 2. Edit Terraform files
# (e.g., add more EC2 instances in modules/ec2/main.tf)

# 3. Format and validate
terraform fmt -recursive
terraform validate

# 4. Push and create PR
git add .
git commit -m "Add additional EC2 instances"
git push origin feature/add-instances

# 5. Create PR on GitHub
# 6. Review plan in PR comments
# 7. Merge when ready
# 8. Auto-deploys to AWS
```

### Run Security Scan Locally
```bash
# Install Checkov
pip install checkov

# Run scan
checkov -d . --framework terraform

# Or use Makefile
make checkov
```

### Manual Plan/Apply
```bash
# Using Makefile
make plan
make apply

# Or directly
terraform init
terraform plan
terraform apply
```

### Destroy Infrastructure
**Option 1: GitHub Actions (Recommended)**
1. Go to Actions tab
2. Select "Terraform CI/CD with Checkov"
3. Click "Run workflow"
4. Select action: "destroy"
5. Approve in environment

**Option 2: Locally**
```bash
terraform destroy
```

## 📚 Documentation Guide

### For First-Time Setup
1. Start with: **SETUP_GUIDE.md**
2. Follow: **CHECKLIST.md**
3. Verify: Run `setup-verify.ps1`

### For Daily Use
1. Commands: **QUICK_REFERENCE.md**
2. Workflow: **GITHUB_ACTIONS_README.md**
3. Help: **README.md**

### For Understanding
1. Architecture: **ARCHITECTURE.md**
2. Structure: **PROJECT_STRUCTURE.md**
3. Deliverables: **DELIVERABLES.md**

## 🐛 Troubleshooting

### Workflow Fails
```bash
# Check workflow logs in Actions tab
# Common issues:

1. AWS Credentials Invalid
   → Verify secrets in GitHub
   → Test locally: aws sts get-caller-identity

2. AMI ID Not Found
   → Get AMI for your region
   → Update secret with correct AMI

3. Key Pair Not Found
   → Create key pair in AWS Console
   → Update KEY_NAME secret

4. Checkov Fails
   → Review security report
   → Fix issues or add exceptions
```

### Terraform Errors
```bash
# Format issues
terraform fmt -recursive

# Validation errors
terraform validate

# State issues
terraform init -reconfigure

# Full reset
rm -rf .terraform
terraform init
```

### Can't SSH to Instance
```bash
# Check security group allows your IP
# Get your IP
curl ifconfig.me

# Update ALLOWED_SSH_CIDR secret
# Re-run workflow to update SG
```

## 💡 Tips & Best Practices

### Development
✅ Always create PRs for changes
✅ Review Terraform plan before merging
✅ Check Checkov reports
✅ Use feature branches
✅ Write descriptive commit messages

### Security
✅ Never commit .tfvars files
✅ Use GitHub Secrets for credentials
✅ Enable branch protection
✅ Require PR reviews
✅ Review security scan results

### Cost Management
✅ Use t2.micro for testing (free tier)
✅ Destroy when not needed
✅ Monitor AWS billing
✅ Set up billing alerts
✅ Review resource usage

## 🎓 Learning Path

### Beginner
1. ✅ Run setup-verify.ps1
2. ✅ Read SETUP_GUIDE.md
3. ✅ Configure GitHub secrets
4. ✅ Create first PR
5. ✅ Deploy infrastructure

### Intermediate
1. ⭐ Customize Terraform modules
2. ⭐ Modify workflow jobs
3. ⭐ Add S3 backend
4. ⭐ Setup pre-commit hooks
5. ⭐ Configure environments

### Advanced
1. 🚀 Multi-environment setup
2. 🚀 Cost estimation (Infracost)
3. 🚀 Automated testing
4. 🚀 Drift detection
5. 🚀 Custom Checkov policies

## 📞 Need Help?

### Documentation
- **SETUP_GUIDE.md** - Full setup instructions
- **QUICK_REFERENCE.md** - Command cheat sheet
- **CHECKLIST.md** - Step-by-step tasks
- **Troubleshooting** - In SETUP_GUIDE.md

### Resources
- [Terraform Docs](https://www.terraform.io/docs)
- [GitHub Actions](https://docs.github.com/en/actions)
- [Checkov](https://www.checkov.io/)
- [AWS Docs](https://docs.aws.amazon.com/)

### Tools
- `setup-verify.ps1` - Verify setup
- `Makefile` - Common commands
- `.pre-commit` - Git hooks

## ✨ Next Steps

After completing basic setup:

### Immediate
1. [ ] Test all workflows
2. [ ] Verify AWS resources
3. [ ] Review security reports
4. [ ] Check costs in AWS billing

### Short Term
1. [ ] Setup S3 backend
2. [ ] Configure branch protection
3. [ ] Add team members as reviewers
4. [ ] Setup billing alerts

### Long Term
1. [ ] Multi-environment strategy
2. [ ] Automated testing
3. [ ] Monitoring & alerting
4. [ ] Cost optimization

## 🎉 Success Criteria

You're done when:
- ✅ All workflows run successfully
- ✅ Infrastructure deploys to AWS
- ✅ PR comments show plans
- ✅ Security scans complete
- ✅ Documentation reviewed
- ✅ Cleanup works (destroy)

## 📝 Checklist

### Setup Phase
- [ ] Tools installed and verified
- [ ] GitHub repository created
- [ ] Secrets configured
- [ ] Environments setup (optional)
- [ ] Branch protection enabled (optional)

### Testing Phase
- [ ] First PR created
- [ ] Workflow runs successfully
- [ ] Security scan completes
- [ ] Plan shows in PR comment
- [ ] Merge and deploy works

### Verification Phase
- [ ] AWS resources created
- [ ] Can access EC2 instances
- [ ] Outputs saved in artifacts
- [ ] Documentation reviewed
- [ ] Destroy works

### Submission Phase
- [ ] All code committed
- [ ] Workflows passing
- [ ] Screenshots taken
- [ ] Documentation complete
- [ ] Ready for grading

---

## 🏁 Final Notes

**Time to Complete**: 30-60 minutes
**Difficulty**: Intermediate
**Prerequisites**: Basic Terraform, AWS, Git knowledge

**What Makes This Special**:
- ✅ Fully automated CI/CD
- ✅ Security-first approach
- ✅ Production-ready setup
- ✅ Comprehensive documentation
- ✅ Best practices included

**You're Ready!** 🚀

Start with:
```powershell
./setup-verify.ps1
```

Then follow the steps above. Good luck!

---
**Course**: NT548.Q11 - Infrastructure Automation
**LAB**: 2 - Terraform + GitHub Actions + Checkov
**Points**: 3/3 (if all requirements met)
