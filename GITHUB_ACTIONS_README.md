# GitHub Actions Workflow Documentation

## Tổng quan
Workflow này tự động hóa quá trình triển khai Terraform lên AWS với các bước kiểm tra bảo mật và tuân thủ.

## Các Jobs

### 1. Security Scan (Checkov)
- **Mục đích**: Kiểm tra bảo mật và tuân thủ code Terraform
- **Công cụ**: Checkov
- **Khi chạy**: Mỗi khi push hoặc tạo pull request
- **Output**: Báo cáo XML được upload làm artifact
- **Lưu ý**: Nếu Checkov phát hiện issue theo cấu hình trong `.checkov.yml` thì job sẽ **fail** (để chặn merge nếu bạn bật branch protection).

### 2. Terraform Validate
- **Mục đích**: Kiểm tra format và validate cú pháp Terraform
- **Khi chạy**: Mỗi khi push hoặc tạo pull request
- **Checks**:
  - `terraform fmt -check`: Kiểm tra code formatting
  - `terraform validate`: Validate cấu hình Terraform

### 3. Terraform Plan
- **Mục đích**: Tạo execution plan để xem trước các thay đổi
- **Khi chạy**:
  - Trên pull requests (chỉ khi PR không phải từ fork vì fork không có quyền dùng secrets)
  - Hoặc manual trigger `workflow_dispatch` với action = `plan`
- **Output**: 
  - Plan được lưu làm artifact
  - Comment trên PR với kết quả plan

### 4. Terraform Apply
- **Mục đích**: Triển khai infrastructure lên AWS
- **Khi chạy**:
  - Tự động khi push/merge vào branch `main`
  - Hoặc manual trigger `workflow_dispatch` với action = `apply` (khuyến nghị chạy trên branch `main`)
- **Environment**: `production` (yêu cầu manual approval nếu được cấu hình)
- **Output**: Terraform outputs được lưu làm artifact

### 5. Terraform Destroy
- **Mục đích**: Xóa toàn bộ infrastructure
- **Khi chạy**: Manual trigger only (workflow_dispatch)
- **Environment**: `production-destroy` (yêu cầu manual approval)

## Secrets cần thiết

Cấu hình các secrets sau trong GitHub repository:

### AWS Credentials
- `AWS_ACCESS_KEY_ID`: AWS Access Key ID
- `AWS_SECRET_ACCESS_KEY`: AWS Secret Access Key

### Terraform Variables
- `ALLOWED_SSH_CIDR`: CIDR block cho phép SSH (ví dụ: "0.0.0.0/0")
- `KEY_NAME`: Tên EC2 Key Pair trên AWS
- `AMI_ID`: AMI ID cho EC2 instances
- `INSTANCE_TYPE`: Loại EC2 instance (ví dụ: "t2.micro")

## Cách thêm Secrets

1. Vào repository trên GitHub
2. Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. Thêm từng secret với tên và giá trị tương ứng

## Cách sử dụng

### Pull Request Workflow
1. Tạo branch mới từ `main`
2. Thực hiện thay đổi code Terraform
3. Push code lên GitHub
4. Tạo Pull Request
5. Workflow sẽ tự động:
   - Chạy Checkov security scan
   - Validate Terraform code
   - Tạo và comment Terraform plan trên PR
6. Review kết quả và merge nếu OK

 Nếu PR đến từ fork, job `Terraform Plan` sẽ bị skip vì GitHub không cấp secrets cho workflow trên fork.

### Deployment Workflow
1. Merge PR vào branch `main`
2. Workflow tự động chạy `terraform apply`
3. Infrastructure được triển khai lên AWS
4. Kiểm tra outputs trong artifacts

### Manual Destroy
1. Vào Actions tab trên GitHub
2. Chọn workflow "Terraform CI/CD with Checkov"
3. Click "Run workflow"
4. Chọn branch và confirm
5. Infrastructure sẽ bị xóa

## Manual Plan/Apply

1. Vào tab **Actions** → chọn workflow **Terraform CI/CD with Checkov**
2. Click **Run workflow**
3. Chọn branch (khuyến nghị `main`)
4. Chọn input `action`: `plan` hoặc `apply`

## Environments

Nên cấu hình environments trong GitHub để bảo vệ:

### Production Environment
- Settings → Environments → New environment: `production`
- Thêm protection rules:
  -  Required reviewers (1-6 reviewers)
  -  Wait timer (optional)
  -  Restrict to specific branches: `main`

### Production Destroy Environment
- Settings → Environments → New environment: `production-destroy`
- Thêm protection rules:
  -  Required reviewers (ít nhất 2 reviewers)
  -  Cảnh báo: Environment này cho phép destroy infrastructure

## Backend Configuration (Optional)

Để lưu trữ Terraform state an toàn, nên sử dụng S3 backend:

```hcl
terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "lab2/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

## Troubleshooting

### Checkov failures
- Review security report trong artifacts
- Fix các issues hoặc thêm exceptions trong `.checkov.yml`

### Terraform plan/apply failures
- Kiểm tra AWS credentials
- Verify các secrets được cấu hình đúng
- Review error logs trong workflow run

### Format check failures
- Run locally: `terraform fmt -recursive`
- Commit và push lại

## Best Practices

1. **Luôn tạo PR** trước khi merge vào main
2. **Review Checkov reports** để đảm bảo bảo mật
3. **Kiểm tra Terraform plan** trước khi approve merge
4. **Sử dụng branch protection** trên main branch
5. **Enable manual approval** cho production environment
6. **Sử dụng S3 backend** cho state management
7. **Tag releases** để theo dõi deployments
