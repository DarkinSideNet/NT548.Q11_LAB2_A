# Makefile for Terraform Operations
# Sử dụng: make <target>

.PHONY: help init plan apply destroy fmt validate clean check-secrets install-tools

# Default target
help:
	@echo "Available targets:"
	@echo "  init           - Initialize Terraform"
	@echo "  fmt            - Format Terraform files"
	@echo "  validate       - Validate Terraform configuration"
	@echo "  plan           - Show Terraform plan"
	@echo "  apply          - Apply Terraform changes"
	@echo "  destroy        - Destroy all resources"
	@echo "  clean          - Clean Terraform files"
	@echo "  check-secrets  - Check for hardcoded secrets"
	@echo "  checkov        - Run Checkov security scan"
	@echo "  install-tools  - Install required tools"
	@echo "  test           - Run all checks (fmt, validate, checkov)"

# Install required tools
install-tools:
	@echo "Installing Checkov..."
	pip install checkov
	@echo "Installing tfsec..."
	@command -v tfsec || (curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash)
	@echo "Tools installed successfully!"

# Initialize Terraform
init:
	@echo "Initializing Terraform..."
	terraform init

# Format Terraform files
fmt:
	@echo "Formatting Terraform files..."
	terraform fmt -recursive

# Validate Terraform configuration
validate: init
	@echo "Validating Terraform configuration..."
	terraform validate

# Show Terraform plan
plan: init
	@echo "Generating Terraform plan..."
	terraform plan

# Apply Terraform changes
apply: init
	@echo "Applying Terraform changes..."
	terraform apply

# Destroy all resources
destroy: init
	@echo "Destroying all resources..."
	terraform destroy

# Clean Terraform files
clean:
	@echo "Cleaning Terraform files..."
	rm -rf .terraform
	rm -f .terraform.lock.hcl
	rm -f terraform.tfstate
	rm -f terraform.tfstate.backup
	rm -f tfplan
	@echo "Clean complete!"

# Check for hardcoded secrets
check-secrets:
	@echo "Checking for hardcoded secrets..."
	@grep -r -i -E "(aws_access_key_id|aws_secret_access_key|password|secret)" --include="*.tf" . || echo "No hardcoded secrets found"

# Run Checkov security scan
checkov:
	@echo "Running Checkov security scan..."
	checkov --directory . --framework terraform --compact --soft-fail

# Run tfsec scan
tfsec:
	@echo "Running tfsec security scan..."
	tfsec .

# Run all checks
test: fmt validate checkov
	@echo "All checks passed!"

# Quick deploy (format, validate, plan, apply)
deploy: fmt validate plan apply
	@echo "Deployment complete!"
