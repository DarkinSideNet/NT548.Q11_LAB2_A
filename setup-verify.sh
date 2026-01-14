#!/usr/bin/env bash

# LAB 2 - Setup Verification Script (Linux/macOS)
# Usage: bash ./setup-verify.sh
# Optional: chmod +x setup-verify.sh && ./setup-verify.sh

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

# --------- Color helpers (only if stdout is a TTY) ---------
if [ -t 1 ]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[0;33m'
  CYAN='\033[0;36m'
  GRAY='\033[0;90m'
  NC='\033[0m'
else
  RED='' ; GREEN='' ; YELLOW='' ; CYAN='' ; GRAY='' ; NC=''
fi

errors=()
warnings=()

add_error()   { errors+=("$1"); }
add_warning() { warnings+=("$1"); }

command_exists() { command -v "$1" >/dev/null 2>&1; }

print_header() {
  echo -e "${CYAN}==================================${NC}"
  echo -e "${CYAN}$1${NC}"
  echo -e "${CYAN}==================================${NC}"
}

print_check() {
  # $1 label
  # $2 status (OK|NOT FOUND|FAILED|...)
  # $3 color
  printf "%s %b%s%b\n" "$1" "$3" "$2" "$NC"
}

print_header "LAB 2 - Setup Verification Script"

# 1) Check Terraform
printf "Checking Terraform..."
if command_exists terraform; then
  tf_ver="$(terraform version 2>/dev/null | head -n 1 | tr -d '\r')"
  echo -e " ${GREEN}OK${NC} ${GRAY}(${tf_ver})${NC}"
else
  echo -e " ${RED}NOT FOUND${NC}"
  add_error "Terraform not installed. Install: https://www.terraform.io/downloads"
fi

# 2) Check AWS CLI
printf "Checking AWS CLI..."
if command_exists aws; then
  aws_ver="$(aws --version 2>&1 | tr -d '\r')"
  echo -e " ${GREEN}OK${NC} ${GRAY}(${aws_ver})${NC}"
else
  echo -e " ${RED}NOT FOUND${NC}"
  add_error "AWS CLI not installed. See: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
fi

# 3) Check Git
printf "Checking Git..."
if command_exists git; then
  git_ver="$(git --version 2>/dev/null | tr -d '\r')"
  echo -e " ${GREEN}OK${NC} ${GRAY}(${git_ver})${NC}"
else
  echo -e " ${RED}NOT FOUND${NC}"
  add_error "Git not installed. Install: https://git-scm.com/downloads"
fi

# 4) Check Python (for Checkov)
printf "Checking Python..."
if command_exists python3; then
  py_ver="$(python3 --version 2>/dev/null | tr -d '\r')"
  echo -e " ${GREEN}OK${NC} ${GRAY}(${py_ver})${NC}"
elif command_exists python; then
  py_ver="$(python --version 2>/dev/null | tr -d '\r')"
  echo -e " ${YELLOW}OK${NC} ${GRAY}(${py_ver})${NC}"
  add_warning "Using 'python' instead of 'python3'. If Checkov install fails, install Python 3 and pip."
else
  echo -e " ${YELLOW}NOT FOUND${NC}"
  add_warning "Python not installed. Needed for Checkov. Install: https://www.python.org/downloads/"
fi

# 5) Check pip
printf "Checking pip..."
if command_exists pip3; then
  pip_ver="$(pip3 --version 2>/dev/null | tr -d '\r')"
  echo -e " ${GREEN}OK${NC} ${GRAY}(${pip_ver})${NC}"
elif command_exists pip; then
  pip_ver="$(pip --version 2>/dev/null | tr -d '\r')"
  echo -e " ${YELLOW}OK${NC} ${GRAY}(${pip_ver})${NC}"
  add_warning "Using 'pip' instead of 'pip3'."
else
  echo -e " ${YELLOW}NOT FOUND${NC}"
  add_warning "pip not found. Needed to install Checkov."
fi

# 6) Check Checkov
printf "Checking Checkov..."
if command_exists checkov; then
  ck_ver="$(checkov --version 2>/dev/null | tr -d '\r')"
  echo -e " ${GREEN}OK${NC} ${GRAY}(${ck_ver})${NC}"
else
  echo -e " ${YELLOW}NOT FOUND${NC}"
  add_warning "Checkov not installed. Install with: pip3 install checkov"
fi

echo
print_header "Checking AWS Configuration"

# 7) Check AWS Credentials
printf "Checking AWS Credentials..."
if command_exists aws; then
  identity_json="$(aws sts get-caller-identity --output json 2>/dev/null || true)"
  if [ -n "$identity_json" ]; then
    echo -e " ${GREEN}OK${NC}"
    if command_exists jq; then
      acct="$(echo "$identity_json" | jq -r '.Account' 2>/dev/null || true)"
      arn="$(echo "$identity_json" | jq -r '.Arn' 2>/dev/null || true)"
      [ -n "$acct" ] && echo -e "  ${GRAY}Account:${NC} $acct"
      [ -n "$arn" ] && echo -e "  ${GRAY}Arn:${NC} $arn"
    else
      echo -e "  ${GRAY}Tip:${NC} Install 'jq' to pretty-print identity output."
    fi
  else
    echo -e " ${RED}FAILED${NC}"
    add_error "AWS credentials not configured. Run: aws configure (or export AWS_ACCESS_KEY_ID/AWS_SECRET_ACCESS_KEY)"
  fi
else
  echo -e " ${YELLOW}SKIPPED${NC}"
fi

echo
print_header "Checking Project Files"

required_files=(
  "main.tf"
  "variables.tf"
  "outputs.tf"
  "providers.tf"
  ".github/workflows/terraform.yml"
  ".checkov.yml"
  ".gitignore"
)

for f in "${required_files[@]}"; do
  printf "Checking %s..." "$f"
  if [ -f "$f" ]; then
    echo -e " ${GREEN}OK${NC}"
  else
    echo -e " ${RED}NOT FOUND${NC}"
    add_error "Missing file: $f"
  fi
done

printf "Checking terraform.tfvars..."
if [ -f "terraform.tfvars" ]; then
  echo -e " ${YELLOW}FOUND${NC}"
  add_warning "terraform.tfvars exists. Ensure it is NOT committed (it's in .gitignore)."
else
  echo -e " ${GREEN}NOT FOUND (OK)${NC}"
  echo -e "  ${GRAY}Copy terraform.tfvars.example → terraform.tfvars and fill values (local only).${NC}"
fi

echo
printf "Checking Modules..."
modules_ok=true
for m in vpc security_groups ec2; do
  if [ ! -f "modules/$m/main.tf" ]; then
    modules_ok=false
    add_error "Missing module: modules/$m/main.tf"
  fi
done
if $modules_ok; then
  echo -e " ${GREEN}OK${NC}"
else
  echo -e " ${RED}MISSING${NC}"
fi

echo
print_header "Running Terraform Checks"

if command_exists terraform; then
  printf "Running terraform fmt -check..."
  if terraform fmt -check -recursive >/dev/null 2>&1; then
    echo -e " ${GREEN}OK${NC}"
  else
    echo -e " ${YELLOW}FORMATTING NEEDED${NC}"
    add_warning "Run: terraform fmt -recursive"
  fi

  printf "Running terraform init -backend=false..."
  if terraform init -backend=false >/dev/null 2>&1; then
    echo -e " ${GREEN}OK${NC}"

    printf "Running terraform validate..."
    if terraform validate >/dev/null 2>&1; then
      echo -e " ${GREEN}OK${NC}"
    else
      echo -e " ${RED}FAILED${NC}"
      add_error "Terraform validation failed. Run: terraform validate to see details."
    fi
  else
    echo -e " ${RED}FAILED${NC}"
    add_error "Terraform init failed. Run: terraform init -backend=false to see details."
  fi
else
  echo -e "${YELLOW}Terraform not found; skipping terraform checks.${NC}"
fi

echo
print_header "Checking Git Configuration"

printf "Checking Git repository..."
if [ -d ".git" ]; then
  echo -e " ${GREEN}OK${NC}"
  if command_exists git; then
    if git remote -v 2>/dev/null | grep -q '^origin\s'; then
      echo -e "  ${GREEN}Remote configured: OK${NC}"
    else
      echo -e "  ${YELLOW}Remote not configured${NC}"
      add_warning "Add GitHub remote: git remote add origin <url>"
    fi
  fi
else
  echo -e " ${YELLOW}NOT INITIALIZED${NC}"
  add_warning "Initialize Git repository: git init"
fi

echo
print_header "Summary"

if [ ${#errors[@]} -eq 0 ] && [ ${#warnings[@]} -eq 0 ]; then
  echo -e "${GREEN}✓ All checks passed!${NC}"
  echo
  echo -e "${CYAN}Next steps:${NC}"
  echo "1. Create terraform.tfvars from terraform.tfvars.example (local only)"
  echo "2. Configure GitHub repo secrets"
  echo "3. Open a PR to see Checkov + Terraform Plan comments"
else
  if [ ${#errors[@]} -gt 0 ]; then
    echo -e "${RED}ERRORS (${#errors[@]}):${NC}"
    for e in "${errors[@]}"; do
      echo -e "  ${RED}✗${NC} $e"
    done
  fi

  if [ ${#warnings[@]} -gt 0 ]; then
    echo
    echo -e "${YELLOW}WARNINGS (${#warnings[@]}):${NC}"
    for w in "${warnings[@]}"; do
      echo -e "  ${YELLOW}!${NC} $w"
    done
  fi
fi

echo
print_header "Documentation"
echo "- SETUP_GUIDE.md"
echo "- CHECKLIST.md"
echo "- QUICK_REFERENCE.md"
echo "- ARCHITECTURE.md"
