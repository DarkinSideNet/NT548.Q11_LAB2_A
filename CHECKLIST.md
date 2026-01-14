# Checklist Setup GitHub Actions và Terraform

## ✅ Checklist hoàn thành LAB 2

### Phase 1: Setup Repository (15 phút)
- [ ] Tạo GitHub repository mới
- [ ] Push code Terraform hiện tại lên GitHub
- [ ] Verify tất cả files đã được push
- [ ] Kiểm tra `.gitignore` hoạt động đúng (không commit `.tfvars`, `.tfstate`)

### Phase 2: Cấu hình GitHub Secrets (10 phút)
- [ ] Tạo AWS Access Key và Secret Key
- [ ] Thêm secret: `AWS_ACCESS_KEY_ID`
- [ ] Thêm secret: `AWS_SECRET_ACCESS_KEY`
- [ ] Thêm secret: `ALLOWED_SSH_CIDR`
- [ ] Thêm secret: `KEY_NAME`
- [ ] Thêm secret: `AMI_ID`
- [ ] Thêm secret: `INSTANCE_TYPE`
- [ ] Verify tất cả secrets đã được thêm

### Phase 3: Cấu hình GitHub Environments (10 phút)
- [ ] Tạo environment: `production`
  - [ ] Thêm required reviewers
  - [ ] Cấu hình deployment branches (main only)
- [ ] Tạo environment: `production-destroy`
  - [ ] Thêm required reviewers (ít nhất 1)
  - [ ] Thêm warning message

### Phase 4: Branch Protection (5 phút)
- [ ] Bật branch protection cho `main`
- [ ] Require pull request reviews
- [ ] Require status checks to pass
- [ ] Require branches to be up to date
- [ ] Không cho phép force push

### Phase 5: Test Workflow (20 phút)

#### Test 1: Security Scan
- [ ] Tạo branch mới: `test/checkov`
- [ ] Push một số thay đổi
- [ ] Tạo Pull Request
- [ ] Verify Checkov job chạy thành công
- [ ] Download và review security report
- [ ] Fix security issues nếu có
- [ ] Merge PR hoặc đóng

#### Test 2: Format & Validate
- [ ] Tạo branch mới: `test/validate`
- [ ] Intentionally tạo lỗi format (bỏ indent)
- [ ] Push và tạo PR
- [ ] Verify format check fails
- [ ] Fix format với `terraform fmt`
- [ ] Verify check passes
- [ ] Merge hoặc đóng PR

#### Test 3: Terraform Plan
- [ ] Tạo branch mới: `test/plan`
- [ ] Thay đổi nhỏ trong Terraform (ví dụ: tag)
- [ ] Push và tạo PR
- [ ] Verify plan job chạy
- [ ] Review plan output trong PR comment
- [ ] Verify plan artifact được upload
- [ ] Merge hoặc đóng PR

#### Test 4: Deployment
- [ ] Tạo branch: `test/deploy`
- [ ] Thực hiện thay đổi có ý nghĩa
- [ ] Tạo PR và verify tất cả checks pass
- [ ] Merge vào `main`
- [ ] Verify workflow `terraform apply` chạy
- [ ] Approve deployment nếu có environment protection
- [ ] Kiểm tra resources trên AWS Console
- [ ] Download và verify terraform outputs

### Phase 6: Verify Deployment (15 phút)
- [ ] Đăng nhập AWS Console
- [ ] Verify VPC đã được tạo
- [ ] Verify Subnets (public & private)
- [ ] Verify Route Tables
- [ ] Verify NAT Gateway
- [ ] Verify Security Groups
- [ ] Verify EC2 Instances (public & private)
- [ ] Test SSH vào public instance (nếu có)
- [ ] Verify private instance có thể access internet qua NAT

### Phase 7: Documentation (10 phút)
- [ ] Cập nhật README.md với:
  - [ ] Badge trạng thái workflow
  - [ ] Thông tin project
  - [ ] Link đến documentation
- [ ] Review SETUP_GUIDE.md
- [ ] Review GITHUB_ACTIONS_README.md
- [ ] Thêm screenshots vào documentation (optional)

### Phase 8: Advanced Features (Optional - 20 phút)
- [ ] Setup S3 backend cho Terraform state
  - [ ] Tạo S3 bucket
  - [ ] Enable versioning
  - [ ] Enable encryption
  - [ ] Tạo DynamoDB table cho locking
  - [ ] Cập nhật backend config
  - [ ] Migrate state
- [ ] Setup pre-commit hooks
  - [ ] Install pre-commit
  - [ ] Run `pre-commit install`
  - [ ] Test pre-commit hooks
- [ ] Thêm cost estimation (Infracost)
- [ ] Setup notifications (Slack/Email)

### Phase 9: Testing & Validation (15 phút)
- [ ] Test manual plan workflow
  - [ ] Trigger workflow với action = "plan"
  - [ ] Review output
- [ ] Test manual destroy workflow (cẩn thận!)
  - [ ] Trigger workflow với action = "destroy"
  - [ ] Approve destruction
  - [ ] Verify resources bị xóa
  - [ ] Deploy lại với apply

### Phase 10: Final Review (10 phút)
- [ ] Review tất cả workflows trong Actions tab
- [ ] Verify không có secrets bị exposed trong logs
- [ ] Review security scan reports
- [ ] Kiểm tra cost trên AWS Billing
- [ ] Clean up test branches
- [ ] Update documentation với lessons learned

## 📊 Deliverables

### Code & Configuration
- [x] Terraform modules (VPC, EC2, Security Groups)
- [x] GitHub Actions workflow file
- [x] Checkov configuration
- [x] Documentation files

### GitHub Setup
- [ ] Repository với code hoàn chỉnh
- [ ] Configured secrets
- [ ] Configured environments
- [ ] Branch protection enabled
- [ ] Successful workflow runs

### Documentation
- [x] README.md
- [x] SETUP_GUIDE.md
- [x] GITHUB_ACTIONS_README.md
- [x] Pull Request template
- [x] Issue templates

### Evidence (Screenshots)
- [ ] GitHub Actions workflow run success
- [ ] Checkov security scan results
- [ ] Terraform plan output
- [ ] AWS Console showing deployed resources
- [ ] GitHub repository settings (secrets, environments)

## 🎯 Rubric (3 điểm)

### Terraform Infrastructure (1 điểm)
- [ ] VPC được triển khai đúng
- [ ] Route Tables hoạt động
- [ ] NAT Gateway configured
- [ ] EC2 instances running
- [ ] Security Groups đúng cấu hình
**Status**: ___/1 điểm

### GitHub Actions Automation (1 điểm)
- [ ] Workflow tự động chạy trên PR
- [ ] Workflow tự động deploy trên merge
- [ ] Plan được hiển thị trên PR
- [ ] Proper error handling
- [ ] Artifacts được upload
**Status**: ___/1 điểm

### Checkov Integration (1 điểm)
- [ ] Checkov chạy tự động
- [ ] Security report được tạo
- [ ] Issues được identify
- [ ] Proper configuration (.checkov.yml)
- [ ] Integration với workflow
**Status**: ___/1 điểm

**Tổng điểm**: ___/3 điểm

## 📝 Notes

### Thời gian ước tính
- Setup cơ bản: 1-2 giờ
- Testing & debugging: 1-2 giờ
- Documentation: 30 phút - 1 giờ
- Advanced features: 1-2 giờ (optional)

### Common Pitfalls
1. ❌ Quên cấu hình AWS credentials
2. ❌ Secrets không đúng format
3. ❌ AMI ID không tồn tại trong region
4. ❌ Key Pair chưa được tạo trên AWS
5. ❌ Commit file `.tfvars` vào Git
6. ❌ Không enable branch protection
7. ❌ Quên approve deployment trong environment

### Tips
1. ✅ Test workflow trên branch riêng trước
2. ✅ Sử dụng `t2.micro` cho cost-effective testing
3. ✅ Enable auto-destroy sau X giờ để tiết kiệm
4. ✅ Review Terraform plan cẩn thận trước khi approve
5. ✅ Keep secrets safe, never commit to Git
6. ✅ Use S3 backend cho production
7. ✅ Monitor AWS costs regularly

## 🆘 Support

Nếu gặp vấn đề:
1. Check [SETUP_GUIDE.md](SETUP_GUIDE.md) troubleshooting section
2. Review workflow logs trong Actions tab
3. Verify secrets configuration
4. Check AWS IAM permissions
5. Review Terraform error messages

## ✨ Bonus Points

- [ ] Implement monitoring & alerting
- [ ] Add cost estimation with Infracost
- [ ] Setup multi-environment (dev/staging/prod)
- [ ] Implement automated testing
- [ ] Add drift detection
- [ ] Setup notifications (Slack/Discord)
- [ ] Create video demo
- [ ] Write blog post about setup process
