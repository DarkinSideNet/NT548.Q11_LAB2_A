# Hướng dẫn Setup GitHub Actions

## Bước 1: Tạo Repository trên GitHub

1. Đăng nhập vào GitHub
2. Tạo repository mới (public hoặc private)
3. Clone repository về máy hoặc push code hiện tại lên

```bash
# Nếu chưa có git repo
git init
git add .
git commit -m "Initial commit with Terraform code"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git push -u origin main
```

## Bước 2: Cấu hình GitHub Secrets

### Thêm AWS Credentials

1. Vào repository trên GitHub
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Thêm các secrets sau:

#### AWS_ACCESS_KEY_ID
```
Tên: AWS_ACCESS_KEY_ID
Giá trị: <Your AWS Access Key ID>
```

#### AWS_SECRET_ACCESS_KEY
```
Tên: AWS_SECRET_ACCESS_KEY
Giá trị: <Your AWS Secret Access Key>
```

### Thêm Terraform Variables

#### ALLOWED_SSH_CIDR
```
Tên: ALLOWED_SSH_CIDR
Giá trị: 0.0.0.0/0
(Hoặc IP cụ thể của bạn, ví dụ: 123.45.67.89/32)
```

#### KEY_NAME
```
Tên: KEY_NAME
Giá trị: <Tên EC2 Key Pair của bạn trên AWS>
```

#### AMI_ID
```
Tên: AMI_ID
Giá trị: <AMI ID, ví dụ: ami-0c55b159cbfafe1f0>
```

Để tìm AMI ID:
- Vào AWS Console → EC2 → AMIs
- Hoặc dùng lệnh: `aws ec2 describe-images --owners amazon --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" --query 'Images[0].ImageId'`

#### INSTANCE_TYPE
```
Tên: INSTANCE_TYPE
Giá trị: t2.micro
(hoặc loại instance khác)
```

## Bước 3: Cấu hình Environments (Optional nhưng khuyến nghị)

### Tạo Production Environment

1. Vào **Settings** → **Environments**
2. Click **New environment**
3. Tên: `production`
4. Cấu hình Protection rules:
   - ✅ **Required reviewers**: Chọn người cần approve (có thể là chính bạn)
   - ✅ **Deployment branches**: Chọn "Selected branches" → Thêm `main`
5. Click **Save protection rules**

### Tạo Production Destroy Environment

1. Click **New environment**
2. Tên: `production-destroy`
3. Cấu hình Protection rules:
   - ✅ **Required reviewers**: Chọn ít nhất 1-2 người
   - ⚠️ Environment này dùng để destroy infrastructure, cần cẩn thận
4. Click **Save protection rules**

## Bước 4: Cấu hình Branch Protection (Khuyến nghị)

1. Vào **Settings** → **Branches**
2. Click **Add rule**
3. Branch name pattern: `main`
4. Chọn:
   - ✅ **Require a pull request before merging**
   - ✅ **Require status checks to pass before merging**
     - Tìm và thêm: `Checkov Security Scan`, `Terraform Format & Validate`
   - ✅ **Require branches to be up to date before merging**
   - ✅ **Do not allow bypassing the above settings**
5. Click **Create**

## Bước 5: Test Workflow

### Test với Pull Request

1. Tạo branch mới:
```bash
git checkout -b test-workflow
```

2. Thực hiện thay đổi nhỏ (ví dụ: thêm comment vào file)
```bash
# Sửa file bất kỳ
echo "# Test comment" >> main.tf
git add .
git commit -m "Test GitHub Actions workflow"
git push origin test-workflow
```

3. Tạo Pull Request trên GitHub

4. Kiểm tra workflow chạy:
   - Vào tab **Actions** để xem workflow đang chạy
   - Kiểm tra kết quả của từng job
   - Xem comment trên PR với Terraform plan

### Test Deployment

1. Merge Pull Request vào `main`
2. Workflow sẽ tự động chạy `terraform apply`
3. Kiểm tra trong **Actions** tab
4. Nếu đã cấu hình environment protection, cần approve deployment
5. Sau khi hoàn tất, kiểm tra infrastructure trên AWS Console

## Bước 6: Verify Deployment

### Kiểm tra trên AWS Console

1. Đăng nhập AWS Console
2. Kiểm tra các resources đã được tạo:
   - VPC
   - Subnets
   - Route Tables
   - NAT Gateway
   - Security Groups
   - EC2 Instances

### Kiểm tra Terraform Outputs

1. Vào workflow run trong **Actions** tab
2. Scroll xuống **Artifacts**
3. Download `terraform-outputs`
4. Mở file JSON để xem outputs

## Bước 7: Cleanup (Khi cần)

### Destroy Infrastructure

1. Vào **Actions** tab
2. Chọn workflow "Terraform CI/CD with Checkov"
3. Click **Run workflow**
4. Chọn branch `main`
5. Click **Run workflow**
6. Nếu có environment protection, approve destroy request
7. Infrastructure sẽ bị xóa

## Troubleshooting

### AWS Credentials Invalid
- Kiểm tra lại AWS Access Key và Secret Key
- Verify IAM user có đủ quyền (EC2, VPC, etc.)

### Terraform Plan Fails
- Kiểm tra tất cả secrets đã được cấu hình đúng
- Verify AMI ID tồn tại trong region của bạn
- Kiểm tra Key Pair đã được tạo trong AWS

### Checkov Failures
- Review security report trong artifacts
- Cập nhật code để fix security issues
- Hoặc thêm exceptions trong `.checkov.yml`

### Workflow không chạy
- Kiểm tra file workflow trong `.github/workflows/`
- Verify branch trigger settings
- Kiểm tra repository settings cho phép Actions

## Best Practices

1. ✅ **Không commit secrets** vào code
2. ✅ **Luôn tạo PR** trước khi merge vào main
3. ✅ **Review Terraform plan** trước khi approve
4. ✅ **Sử dụng S3 backend** cho production (xem bên dưới)
5. ✅ **Tag releases** để tracking
6. ✅ **Enable notifications** cho workflow failures

## (Optional) Cấu hình S3 Backend

### Tạo S3 Bucket cho State

```bash
# Tạo S3 bucket
aws s3 mb s3://your-terraform-state-bucket --region us-east-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket your-terraform-state-bucket \
  --versioning-configuration Status=Enabled

# Enable encryption
aws s3api put-bucket-encryption \
  --bucket your-terraform-state-bucket \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'
```

### Tạo DynamoDB Table cho State Locking

```bash
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

### Cập nhật providers.tf

Thêm backend configuration vào file `providers.tf`:

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

Sau đó migrate state:
```bash
terraform init -migrate-state
```

## Next Steps

1. Cấu hình notifications (Slack, Email) cho workflow failures
2. Thêm cost estimation với Infracost
3. Implement automated testing
4. Set up monitoring và alerting cho infrastructure
