# Architecture Documentation

## 🏗️ AWS Infrastructure Architecture

### Network Topology
```
┌─────────────────────────────────────────────────────────────────┐
│                          VPC (10.0.0.0/16)                      │
│                                                                  │
│  ┌────────────────────────┐      ┌─────────────────────────┐   │
│  │   Public Subnet        │      │   Private Subnet        │   │
│  │   10.0.1.0/24          │      │   10.0.2.0/24           │   │
│  │                        │      │                         │   │
│  │  ┌──────────────────┐  │      │  ┌──────────────────┐  │   │
│  │  │  Public EC2      │  │      │  │  Private EC2     │  │   │
│  │  │  Instance        │  │      │  │  Instance        │  │   │
│  │  └────────┬─────────┘  │      │  └────────┬─────────┘  │   │
│  │           │            │      │           │            │   │
│  │  ┌────────▼─────────┐  │      │  ┌────────▼─────────┐  │   │
│  │  │  Public SG       │  │      │  │  Private SG      │  │   │
│  │  │  - SSH (22)      │  │      │  │  - SSH from      │  │   │
│  │  │  - HTTP (80)     │  │      │  │    Public SG     │  │   │
│  │  └──────────────────┘  │      │  └──────────────────┘  │   │
│  │           │            │      │           │            │   │
│  └───────────┼────────────┘      └───────────┼────────────┘   │
│              │                               │                │
│  ┌───────────▼───────────┐       ┌───────────▼──────────┐     │
│  │  Internet Gateway     │       │  NAT Gateway         │     │
│  │  (IGW)                │       │                      │     │
│  └───────────┬───────────┘       └───────────┬──────────┘     │
│              │                               │                │
└──────────────┼───────────────────────────────┼────────────────┘
               │                               │
               ▼                               │
          Internet ◄───────────────────────────┘
```

### Resource Details

#### VPC Configuration
- **CIDR Block**: 10.0.0.0/16
- **DNS Support**: Enabled
- **DNS Hostnames**: Enabled
- **Tenancy**: Default

#### Subnets
| Subnet | CIDR | Type | Availability Zone | Route |
|--------|------|------|-------------------|-------|
| Public | 10.0.1.0/24 | Public | us-east-1a | IGW |
| Private | 10.0.2.0/24 | Private | us-east-1a | NAT |

#### Route Tables
**Public Route Table**:
- 10.0.0.0/16 → local
- 0.0.0.0/0 → Internet Gateway

**Private Route Table**:
- 10.0.0.0/16 → local
- 0.0.0.0/0 → NAT Gateway

#### Security Groups
**Public SG** (public-sg):
- Inbound:
  - SSH (22) from allowed_ssh_cidr
  - HTTP (80) from 0.0.0.0/0
- Outbound:
  - All traffic

**Private SG** (private-sg):
- Inbound:
  - SSH (22) from Public SG
  - All traffic from VPC CIDR
- Outbound:
  - All traffic

#### EC2 Instances
| Instance | Type | Subnet | Security Group | Public IP |
|----------|------|--------|----------------|-----------|
| Public | t2.micro | Public | Public SG | Yes |
| Private | t2.micro | Private | Private SG | No |

## 🔄 CI/CD Pipeline Architecture

### GitHub Actions Workflow Flow
```
┌─────────────────────────────────────────────────────────────────┐
│                         GitHub Repository                        │
│                                                                  │
│  Push/PR Event                                                  │
│       │                                                         │
│       ▼                                                         │
│  ┌────────────────────────────────────────────────────────┐    │
│  │              GitHub Actions Workflow                   │    │
│  │                                                        │    │
│  │  ┌──────────────────┐                                 │    │
│  │  │  Job 1:          │  Run Checkov                    │    │
│  │  │  Security Scan   │  Security Checks                │    │
│  │  └────────┬─────────┘                                 │    │
│  │           │                                            │    │
│  │           ▼                                            │    │
│  │  ┌──────────────────┐                                 │    │
│  │  │  Job 2:          │  terraform fmt                  │    │
│  │  │  Validate        │  terraform validate             │    │
│  │  └────────┬─────────┘                                 │    │
│  │           │                                            │    │
│  │           ▼                                            │    │
│  │  ┌──────────────────┐                                 │    │
│  │  │  Job 3:          │  terraform plan                 │    │
│  │  │  Plan (PR only)  │  Comment on PR                  │    │
│  │  └────────┬─────────┘                                 │    │
│  │           │                                            │    │
│  │           ▼                                            │    │
│  │  ┌──────────────────┐                                 │    │
│  │  │  Job 4:          │  terraform apply                │    │
│  │  │  Apply (main)    │  Deploy to AWS                  │    │
│  │  └────────┬─────────┘                                 │    │
│  │           │                                            │    │
│  │           ▼                                            │    │
│  │  ┌──────────────────┐                                 │    │
│  │  │  Artifacts       │  - Security Reports             │    │
│  │  │                  │  - Terraform Plans              │    │
│  │  │                  │  - Outputs                      │    │
│  │  └──────────────────┘                                 │    │
│  │                                                        │    │
│  └────────────────────────────────────────────────────────┘    │
│                          │                                     │
└──────────────────────────┼─────────────────────────────────────┘
                           │
                           ▼
                  ┌─────────────────┐
                  │   AWS Account   │
                  │                 │
                  │  - VPC          │
                  │  - EC2          │
                  │  - NAT Gateway  │
                  │  - etc.         │
                  └─────────────────┘
```

### Workflow Decision Tree
```
Event Trigger
    │
    ├─ Push to main/develop
    │   ├─ Run Security Scan ✓
    │   ├─ Run Validate ✓
    │   ├─ Skip Plan
    │   └─ Run Apply (if main) ✓
    │
    ├─ Pull Request to main
    │   ├─ Run Security Scan ✓
    │   ├─ Run Validate ✓
    │   ├─ Run Plan ✓
    │   └─ Skip Apply
    │
    └─ Manual Trigger (workflow_dispatch)
        └─ Action Selection
            ├─ plan → Run Plan only
            ├─ apply → Run Apply
            └─ destroy → Run Destroy
```

## 🔐 Security Architecture

### Secret Management Flow
```
Developer
    │
    ├─ Configure GitHub Secrets
    │   ├─ AWS_ACCESS_KEY_ID
    │   ├─ AWS_SECRET_ACCESS_KEY
    │   └─ Terraform Variables
    │
    ▼
GitHub Secrets (Encrypted)
    │
    ├─ Injected at Runtime
    │   (Never exposed in logs)
    │
    ▼
GitHub Actions Runner
    │
    ├─ Configure AWS Credentials
    │
    ▼
AWS API Calls
    │
    └─ Create/Update Resources
```

### Security Layers
1. **Code Level**: 
   - Checkov scans
   - No hardcoded secrets
   - .gitignore protection

2. **GitHub Level**:
   - Encrypted secrets
   - Branch protection
   - Required reviews
   - Environment protection

3. **AWS Level**:
   - IAM least privilege
   - Security groups
   - Network isolation
   - Encryption at rest

## 📊 Data Flow

### Terraform State Management
```
Local Development          GitHub Actions          Remote State
       │                          │                       │
       ├─ terraform init          │                       │
       │      │                   │                       │
       │      └──────────────────────────────────────────▶│
       │                          │               (Download State)
       │                          │                       │
       ├─ terraform plan          │                       │
       │      │                   │                       │
       │      └──────────────────────────────────────────▶│
       │                          │                (Read State)
       │                          │                       │
       ├─ terraform apply         │                       │
       │      │                   │                       │
       │      └──────────────────────────────────────────▶│
       │                          │              (Update State)
       │                          │                       │
       │                   Same flow for                  │
       │                   GitHub Actions                 │
       │                          │                       │
```

### Deployment Flow
```
Developer → Commit → GitHub → Workflow → AWS
    │          │        │         │        │
    │          │        │         │        ├─ VPC
    │          │        │         │        ├─ Subnets
    │          │        │         │        ├─ Route Tables
    │          │        │         │        ├─ IGW/NAT
    │          │        │         │        ├─ Security Groups
    │          │        │         │        └─ EC2 Instances
    │          │        │         │
    │          │        │         └─ Artifacts
    │          │        │              ├─ Reports
    │          │        │              ├─ Plans
    │          │        │              └─ Outputs
    │          │        │
    │          │        └─ PR Comments
    │          │             ├─ Plan Results
    │          │             ├─ Security Scan
    │          │             └─ Validation
    │          │
    │          └─ Version Control
    │               ├─ Code History
    │               └─ Audit Trail
    │
    └─ Local Testing
         ├─ terraform plan
         └─ terraform apply
```

## 🎯 Module Architecture

### Terraform Module Structure
```
Root Module (main.tf)
    │
    ├─ VPC Module
    │   ├─ Creates VPC
    │   ├─ Creates Subnets (Public/Private)
    │   ├─ Creates Internet Gateway
    │   ├─ Creates NAT Gateway
    │   ├─ Creates Route Tables
    │   └─ Outputs: vpc_id, subnet_ids
    │
    ├─ Security Groups Module
    │   ├─ Creates Public SG
    │   ├─ Creates Private SG
    │   ├─ Configures Rules
    │   └─ Outputs: sg_ids
    │
    └─ EC2 Module
        ├─ Creates Public Instance
        ├─ Creates Private Instance
        ├─ Associates SGs
        └─ Outputs: instance_ids, ips
```

### Module Dependencies
```
VPC Module
    │
    ├─ Output: vpc_id ────────────┐
    │                              │
    └─ Output: subnet_ids ─────┐  │
                               │  │
                               ▼  ▼
                     Security Groups Module
                               │
                               │ Output: sg_ids
                               │
                               ▼
                          EC2 Module
```

## 🔄 Environment Strategy

### Multi-Environment Architecture (Future)
```
Repository
    │
    ├─ Branch: main → Production
    │   ├─ workspace: prod
    │   ├─ state: s3://bucket/prod/terraform.tfstate
    │   └─ vars: prod.tfvars
    │
    ├─ Branch: staging → Staging
    │   ├─ workspace: staging
    │   ├─ state: s3://bucket/staging/terraform.tfstate
    │   └─ vars: staging.tfvars
    │
    └─ Branch: develop → Development
        ├─ workspace: dev
        ├─ state: s3://bucket/dev/terraform.tfstate
        └─ vars: dev.tfvars
```

## 📈 Monitoring & Observability (Future Enhancement)

### Proposed Monitoring Stack
```
AWS Resources
    │
    ├─ CloudWatch Metrics
    │   ├─ EC2 CPU/Memory
    │   ├─ Network Traffic
    │   └─ NAT Gateway Stats
    │
    ├─ CloudWatch Logs
    │   ├─ VPC Flow Logs
    │   ├─ Application Logs
    │   └─ System Logs
    │
    └─ CloudWatch Alarms
        ├─ High CPU Alert
        ├─ Network Anomaly
        └─ Cost Threshold
            │
            └─ SNS Topic → Email/Slack
```

## 💰 Cost Architecture

### Cost Breakdown
```
Monthly AWS Costs
    │
    ├─ Compute (EC2)
    │   ├─ 2x t2.micro instances: $16.80
    │   └─ EBS volumes: $2.00
    │   Total: ~$18.80/month
    │
    ├─ Networking
    │   ├─ NAT Gateway: $32.40
    │   ├─ Data Transfer: $9.00 (varies)
    │   └─ Elastic IPs: $3.60
    │   Total: ~$45.00/month
    │
    └─ Storage (if using S3 backend)
        ├─ S3 Storage: $0.23
        └─ DynamoDB: $0.00 (free tier)
        Total: ~$0.23/month

Total Estimated: ~$64.00/month
(With Free Tier: ~$47.00/month)
```

## 🚀 Scalability Considerations

### Future Enhancements
1. **Auto Scaling Groups**: Auto-scale EC2 based on load
2. **Load Balancers**: Distribute traffic across instances
3. **Multi-AZ**: Deploy across multiple availability zones
4. **RDS**: Add managed database
5. **ElastiCache**: Add caching layer
6. **CloudFront**: CDN for static content
7. **ECS/EKS**: Container orchestration

### Scalable Architecture (Future)
```
                    Internet
                       │
                       ▼
              ┌────────────────┐
              │   CloudFront   │
              │      (CDN)     │
              └────────┬───────┘
                       │
                       ▼
              ┌────────────────┐
              │       ALB      │
              │ (Load Balancer)│
              └────────┬───────┘
                       │
            ┌──────────┴──────────┐
            ▼                     ▼
    ┌──────────────┐      ┌──────────────┐
    │  Auto Scaling│      │  Auto Scaling│
    │   Group      │      │   Group      │
    │   (AZ-1)     │      │   (AZ-2)     │
    └──────┬───────┘      └──────┬───────┘
           │                     │
           └──────────┬──────────┘
                      │
                      ▼
              ┌──────────────┐
              │   RDS        │
              │   (Multi-AZ) │
              └──────────────┘
```

## 📚 References

- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [GitHub Actions Security](https://docs.github.com/en/actions/security-guides)
- [Infrastructure as Code Patterns](https://www.hashicorp.com/resources/terraform-recommended-practices)
