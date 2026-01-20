# LAB 2: AWS Infrastructure Automation với Terraform & GitHub Actions

[![Terraform](https://img.shields.io/badge/Terraform-1.7.0-623CE4?logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?logo=amazon-aws)](https://aws.amazon.com/)
[![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-CI%2FCD-2088FF?logo=github-actions)](https://github.com/features/actions)
[![Checkov](https://img.shields.io/badge/Checkov-Security-00C7B7?logo=checkov)](https://www.checkov.io/)

 **LAB 2 - NT548.Q11**: Triển khai hạ tầng AWS tự động với Terraform và GitHub Actions...

##  Mô tả
Project này triển khai hạ tầng AWS sử dụng Terraform và tự động hóa quy trình CI/CD với GitHub Actions, bao gồm kiểm tra bảo mật với Checkov.

##  Features
-  **Infrastructure as Code**: Quản lý hạ tầng AWS với Terraform
-  **Automated CI/CD**: GitHub Actions tự động hóa deployment
-  **Security Scanning**: Tích hợp Checkov cho compliance checks
-  **Pull Request Workflow**: Tự động plan và comment trên PR
-  **Environment Protection**: Manual approval cho production
-  **Cost Optimization**: Theo dõi và tối ưu chi phí

## Kiến trúc hạ tầng

### AWS Resources
- **VPC**: Virtual Private Cloud với CIDR 10.0.0.0/16
- **Subnets**: Public và Private subnets
- **Route Tables**: Routing cho public và private traffic
- **NAT Gateway**: Cho phép private subnet truy cập Internet
- **EC2 Instances**: Public và Private instances
- **Security Groups**: Kiểm soát traffic inbound/outbound

### Cấu trúc Module
```
.
├── main.tf              # Root module
├── variables.tf         # Input variables
├── outputs.tf          # Output values
├── providers.tf        # Provider configuration
├── terraform.tfvars    # Variable values (không commit)
├── modules/
│   ├── vpc/           # VPC module
│   ├── security_groups/ # Security Groups module
│   └── ec2/           # EC2 module
└── .github/
    └── workflows/
        └── terraform.yml # CI/CD workflow
```

## Tính năng GitHub Actions

###  Security Scan
- Tự động quét code với **Checkov**
- Kiểm tra tuân thủ security best practices
- Upload báo cáo bảo mật

###  Validation
- Terraform format check
- Terraform validate
- Comment kết quả trên PR

###  Plan
- Tự động tạo Terraform plan cho PR
- Preview thay đổi trước khi merge
- Comment plan details trên PR

###  Deploy
- Tự động deploy khi merge vào `main`
- Manual approval với GitHub Environments
- Upload outputs làm artifacts

###  Destroy
- Manual trigger để destroy infrastructure
- Protected environment với approvals
- Safety checks

## Yêu cầu

### Tools
- Terraform >= 1.3.0
- AWS CLI
- Git
- GitHub account

### AWS Permissions
IAM user cần có quyền:
- EC2 full access
- VPC full access
- IAM (nếu cần tạo roles)

## Quick Start

### 1. Clone Repository
```bash
git clone <repository-url>
cd LAB_2
```

### 2. Cấu hình AWS Credentials
```bash
aws configure
```

### 3. Setup GitHub Secrets
Xem chi tiết trong [SETUP_GUIDE.md](SETUP_GUIDE.md)

Required secrets:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `ALLOWED_SSH_CIDR`
- `KEY_NAME`
- `AMI_ID`
- `INSTANCE_TYPE`

### 4. Test Local (Optional)
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
```

### 5. Push to GitHub
```bash
git add .
git commit -m "Initial setup"
git push origin main
```

## Workflow

### Development Workflow
1. Tạo feature branch
```bash
git checkout -b feature/your-feature
```

2. Thực hiện thay đổi

3. Push và tạo Pull Request
```bash
git add .
git commit -m "Your changes"
git push origin feature/your-feature
```

4. GitHub Actions sẽ tự động:
   -  Run Checkov security scan
   -  Validate Terraform code
   -  Generate Terraform plan
   -  Comment results on PR

5. Review và merge PR

6. Auto-deploy khi merge vào `main`

## Checkov Security Checks

Workflow tích hợp Checkov để kiểm tra:
-  IMDSv2 enabled cho EC2
-  EBS volumes được encrypted
-  Security groups restrictions
-  VPC Flow Logs
-  Best practices compliance

Xem cấu hình trong [.checkov.yml](.checkov.yml)

## Documentation

- [SETUP_GUIDE.md](SETUP_GUIDE.md) - Hướng dẫn setup chi tiết
- [GITHUB_ACTIONS_README.md](GITHUB_ACTIONS_README.md) - Chi tiết về GitHub Actions workflow

## Monitoring

### View Workflow Runs
1. Vào tab **Actions** trên GitHub
2. Chọn workflow run để xem details
3. Download artifacts (plans, reports, outputs)

### Check Deployed Resources
```bash
# List EC2 instances
aws ec2 describe-instances --filters "Name=tag:ManagedBy,Values=Terraform"

# List VPCs
aws ec2 describe-vpcs --filters "Name=tag:ManagedBy,Values=Terraform"
```

## Cleanup

### Destroy Infrastructure
1. Vào **Actions** tab
2. Select **Terraform CI/CD with Checkov**
3. Click **Run workflow**
4. Select branch và confirm
5. Approve trong environment (nếu có protection)

Hoặc local:
```bash
terraform destroy
```

## Troubleshooting

### Common Issues

**Issue**: Terraform plan fails với authentication error
```
Solution: Kiểm tra AWS credentials trong GitHub Secrets
```

**Issue**: Checkov báo lỗi security
```
Solution: Review báo cáo trong artifacts và fix issues hoặc thêm exceptions
```

**Issue**: Workflow không trigger
```
Solution: Kiểm tra .github/workflows/terraform.yml và branch settings
```

Xem thêm trong [SETUP_GUIDE.md](SETUP_GUIDE.md#troubleshooting)

## Security Best Practices

1.  Không commit sensitive data (`.tfvars`, keys)
2.  Sử dụng GitHub Secrets cho credentials
3.  Enable branch protection trên `main`
4.  Require PR reviews trước khi merge
5.  Enable manual approval cho production deploys
6.  Regular security scans với Checkov
7.  Sử dụng S3 backend cho state management

## Cost Optimization

Resources được tạo:
- NAT Gateway: ~$0.045/hour + data transfer
- EC2 t2.micro: Free tier eligible hoặc ~$0.0116/hour
- EBS volumes: ~$0.10/GB-month

**Khuyến nghị**: Destroy infrastructure khi không sử dụng để tiết kiệm chi phí.

## Contributing

1. Fork repository
2. Tạo feature branch
3. Commit changes
4. Push to branch
5. Tạo Pull Request

## License

MIT License

## Contact

- Student: [Your Name]
- Course: NT548.Q11 - LAB 2
- School: UIT

## References

- [Terraform Documentation](https://www.terraform.io/docs)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Checkov Documentation](https://www.checkov.io/)
- [AWS Documentation](https://docs.aws.amazon.com/)
