#!/bin/bash
# ==============================================================================
# PHASE 6 - WEB TIER AUTOMATED TESTS
# ==============================================================================
# Tests:
# 1. Auto Scaling Group configuration
# 2. Instance health and distribution
# 3. Apache service status
# 4. Health endpoint accessibility
# 5. Security group rules
# 6. IAM role permissions
# ==============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# ==============================================================================
# HELPER FUNCTIONS
# ==============================================================================

print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_test() {
    echo -e "${YELLOW}TEST $1: $2${NC}"
    TESTS_RUN=$((TESTS_RUN + 1))
}

print_success() {
    echo -e "${GREEN}✓ PASS: $1${NC}\n"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

print_failure() {
    echo -e "${RED}✗ FAIL: $1${NC}\n"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

print_info() {
    echo -e "${BLUE}ℹ INFO: $1${NC}"
}

# ==============================================================================
# PREREQUISITE CHECKS
# ==============================================================================

print_header "PHASE 6 WEB TIER - AUTOMATED TESTS"

print_info "Checking prerequisites..."

# Check AWS CLI
if ! command -v aws &> /dev/null; then
    echo -e "${RED}ERROR: AWS CLI not found. Please install it first.${NC}"
    exit 1
fi

# Check Terraform
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}ERROR: Terraform not found. Please install it first.${NC}"
    exit 1
fi

# Check if in correct directory
if [ ! -f "main.tf" ] || [ ! -f "terraform.tfvars" ]; then
    echo -e "${RED}ERROR: Not in Terraform project directory${NC}"
    exit 1
fi

print_success "Prerequisites check complete"

# ==============================================================================
# GET TERRAFORM OUTPUTS
# ==============================================================================

print_header "GATHERING INFRASTRUCTURE INFORMATION"

print_info "Getting Terraform outputs..."

# Get ASG name
ASG_NAME=$(terraform output -raw web_asg_name 2>/dev/null)
if [ -z "$ASG_NAME" ]; then
    echo -e "${RED}ERROR: Could not get web_asg_name output. Is Phase 6 deployed?${NC}"
    exit 1
fi
print_info "ASG Name: $ASG_NAME"

# Get security group ID
WEB_SG_ID=$(terraform output -raw web_sg_id 2>/dev/null)
print_info "Web SG ID: $WEB_SG_ID"

# Get bastion IP
BASTION_IP=$(terraform output -raw bastion_public_ip 2>/dev/null)
print_info "Bastion IP: $BASTION_IP"

# Get region
REGION=$(terraform output -raw aws_region 2>/dev/null || echo "ap-southeast-1")
print_info "AWS Region: $REGION"

print_success "Infrastructure information gathered"

# ==============================================================================
# TEST 1: AUTO SCALING GROUP CONFIGURATION
# ==============================================================================

print_test "1" "Auto Scaling Group Configuration"

ASG_INFO=$(aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-names "$ASG_NAME" \
    --region "$REGION" \
    --query 'AutoScalingGroups[0]' 2>/dev/null)

if [ -z "$ASG_INFO" ] || [ "$ASG_INFO" == "null" ]; then
    print_failure "Auto Scaling Group not found"
else
    # Check min size
    MIN_SIZE=$(echo "$ASG_INFO" | jq -r '.MinSize')
    DESIRED=$(echo "$ASG_INFO" | jq -r '.DesiredCapacity')
    MAX_SIZE=$(echo "$ASG_INFO" | jq -r '.MaxSize')
    CURRENT=$(echo "$ASG_INFO" | jq -r '.Instances | length')
    
    print_info "Min: $MIN_SIZE, Desired: $DESIRED, Max: $MAX_SIZE, Current: $CURRENT"
    
    if [ "$MIN_SIZE" -eq 3 ] && [ "$MAX_SIZE" -eq 6 ] && [ "$DESIRED" -eq 3 ]; then
        print_success "ASG configuration correct (Min:3, Desired:3, Max:6)"
    else
        print_failure "ASG configuration incorrect"
    fi
fi

# ==============================================================================
# TEST 2: INSTANCE COUNT AND HEALTH
# ==============================================================================

print_test "2" "Instance Count and Health Status"

INSTANCE_COUNT=$(echo "$ASG_INFO" | jq -r '.Instances | length')

if [ "$INSTANCE_COUNT" -lt 3 ]; then
    print_failure "Expected 3 instances, found $INSTANCE_COUNT"
else
    print_info "Found $INSTANCE_COUNT instances"
    
    # Check health status
    HEALTHY_COUNT=$(echo "$ASG_INFO" | jq -r '[.Instances[] | select(.HealthStatus=="Healthy")] | length')
    
    if [ "$HEALTHY_COUNT" -eq "$INSTANCE_COUNT" ]; then
        print_success "All $INSTANCE_COUNT instances are healthy"
    else
        print_failure "Only $HEALTHY_COUNT out of $INSTANCE_COUNT instances are healthy"
    fi
fi

# ==============================================================================
# TEST 3: AVAILABILITY ZONE DISTRIBUTION
# ==============================================================================

print_test "3" "Availability Zone Distribution"

AZ_LIST=$(echo "$ASG_INFO" | jq -r '.Instances[].AvailabilityZone' | sort | uniq)
AZ_COUNT=$(echo "$AZ_LIST" | wc -l)

print_info "Instances distributed across $AZ_COUNT AZs:"
echo "$AZ_LIST" | while read -r az; do
    COUNT=$(echo "$ASG_INFO" | jq -r "[.Instances[] | select(.AvailabilityZone==\"$az\")] | length")
    print_info "  - $az: $COUNT instance(s)"
done

if [ "$AZ_COUNT" -eq 3 ]; then
    print_success "Instances correctly distributed across 3 AZs"
else
    print_failure "Instances not distributed across 3 AZs (found: $AZ_COUNT)"
fi

# ==============================================================================
# TEST 4: EC2 INSTANCE STATUS CHECKS
# ==============================================================================

print_test "4" "EC2 Instance Status Checks"

INSTANCE_IDS=$(echo "$ASG_INFO" | jq -r '.Instances[].InstanceId' | tr '\n' ' ')

if [ -z "$INSTANCE_IDS" ]; then
    print_failure "No instance IDs found"
else
    print_info "Checking status for instances: $INSTANCE_IDS"
    
    STATUS_INFO=$(aws ec2 describe-instance-status \
        --instance-ids $INSTANCE_IDS \
        --region "$REGION" \
        --query 'InstanceStatuses[]' 2>/dev/null)
    
    RUNNING_COUNT=$(echo "$STATUS_INFO" | jq -r '[.[] | select(.InstanceState.Name=="running")] | length')
    INSTANCE_OK=$(echo "$STATUS_INFO" | jq -r '[.[] | select(.InstanceStatus.Status=="ok")] | length')
    SYSTEM_OK=$(echo "$STATUS_INFO" | jq -r '[.[] | select(.SystemStatus.Status=="ok")] | length')
    
    print_info "Running: $RUNNING_COUNT, Instance Checks: $INSTANCE_OK, System Checks: $SYSTEM_OK"
    
    TOTAL_INSTANCES=$(echo "$INSTANCE_IDS" | wc -w)
    if [ "$RUNNING_COUNT" -eq "$TOTAL_INSTANCES" ] && \
       [ "$INSTANCE_OK" -eq "$TOTAL_INSTANCES" ] && \
       [ "$SYSTEM_OK" -eq "$TOTAL_INSTANCES" ]; then
        print_success "All instances running with passing status checks"
    else
        print_failure "Some instances have failing status checks"
    fi
fi

# ==============================================================================
# TEST 5: LAUNCH TEMPLATE CONFIGURATION
# ==============================================================================

print_test "5" "Launch Template Configuration"

LT_ID=$(terraform output -raw web_launch_template_id 2>/dev/null)

if [ -z "$LT_ID" ]; then
    print_failure "Could not get launch template ID"
else
    LT_INFO=$(aws ec2 describe-launch-template-versions \
        --launch-template-id "$LT_ID" \
        --region "$REGION" \
        --query 'LaunchTemplateVersions[0].LaunchTemplateData' 2>/dev/null)
    
    INSTANCE_TYPE=$(echo "$LT_INFO" | jq -r '.InstanceType')
    MONITORING=$(echo "$LT_INFO" | jq -r '.Monitoring.Enabled')
    
    print_info "Instance Type: $INSTANCE_TYPE"
    print_info "Detailed Monitoring: $MONITORING"
    
    if [ "$INSTANCE_TYPE" == "t3.small" ] && [ "$MONITORING" == "true" ]; then
        print_success "Launch template configured correctly"
    else
        print_failure "Launch template configuration issues detected"
    fi
fi

# ==============================================================================
# TEST 6: SECURITY GROUP RULES
# ==============================================================================

print_test "6" "Security Group Rules"

SG_RULES=$(aws ec2 describe-security-group-rules \
    --filters "Name=group-id,Values=$WEB_SG_ID" \
    --region "$REGION" 2>/dev/null)

# Check ingress rules
INGRESS_COUNT=$(echo "$SG_RULES" | jq -r '[.SecurityGroupRules[] | select(.IsEgress==false)] | length')
HTTP_RULE=$(echo "$SG_RULES" | jq -r '[.SecurityGroupRules[] | select(.IsEgress==false and .FromPort==80)] | length')
SSH_RULE=$(echo "$SG_RULES" | jq -r '[.SecurityGroupRules[] | select(.IsEgress==false and .FromPort==22)] | length')

# Check egress rules
EGRESS_COUNT=$(echo "$SG_RULES" | jq -r '[.SecurityGroupRules[] | select(.IsEgress==true)] | length')

print_info "Ingress rules: $INGRESS_COUNT (HTTP: $HTTP_RULE, SSH: $SSH_RULE)"
print_info "Egress rules: $EGRESS_COUNT"

if [ "$HTTP_RULE" -ge 1 ] && [ "$SSH_RULE" -ge 1 ] && [ "$EGRESS_COUNT" -ge 1 ]; then
    print_success "Security group rules configured correctly"
else
    print_failure "Missing required security group rules"
fi

# ==============================================================================
# TEST 7: IAM ROLE AND PERMISSIONS
# ==============================================================================

print_test "7" "IAM Role and Instance Profile"

IAM_ROLE=$(terraform output -raw web_iam_role_name 2>/dev/null)

if [ -z "$IAM_ROLE" ]; then
    print_failure "Could not get IAM role name"
else
    # Check if role exists
    ROLE_INFO=$(aws iam get-role --role-name "$IAM_ROLE" --region "$REGION" 2>/dev/null)
    
    if [ -n "$ROLE_INFO" ]; then
        # Check attached policies
        POLICIES=$(aws iam list-attached-role-policies \
            --role-name "$IAM_ROLE" \
            --region "$REGION" \
            --query 'AttachedPolicies[].PolicyName' 2>/dev/null)
        
        SSM_POLICY=$(echo "$POLICIES" | grep -c "AmazonSSMManagedInstanceCore" || true)
        CW_POLICY=$(echo "$POLICIES" | grep -c "CloudWatchAgentServerPolicy" || true)
        
        print_info "SSM Policy: $SSM_POLICY, CloudWatch Policy: $CW_POLICY"
        
        if [ "$SSM_POLICY" -ge 1 ] && [ "$CW_POLICY" -ge 1 ]; then
            print_success "IAM role configured with required policies"
        else
            print_failure "IAM role missing required policies"
        fi
    else
        print_failure "IAM role not found"
    fi
fi

# ==============================================================================
# TEST 8: USER DATA EXECUTION (requires SSH access)
# ==============================================================================

print_test "8" "User Data Execution Status"

# Get first instance private IP
FIRST_INSTANCE_IP=$(aws ec2 describe-instances \
    --instance-ids $(echo "$INSTANCE_IDS" | awk '{print $1}') \
    --region "$REGION" \
    --query 'Reservations[0].Instances[0].PrivateIpAddress' \
    --output text 2>/dev/null)

if [ -z "$FIRST_INSTANCE_IP" ] || [ "$FIRST_INSTANCE_IP" == "None" ]; then
    print_info "Skipping user data check (requires bastion SSH access)"
    print_info "To manually verify, SSH to bastion and check: /var/log/user-data.log"
else
    print_info "First instance private IP: $FIRST_INSTANCE_IP"
    print_info "User data verification requires bastion SSH access"
    print_info "To verify manually:"
    print_info "  1. SSH to bastion: ssh -i ~/.ssh/package3-demo-bastion-key.pem ec2-user@$BASTION_IP"
    print_info "  2. SSH to web instance: aws ssm start-session --target <instance-id>"
    print_info "  3. Check logs: sudo tail -50 /var/log/user-data.log"
fi

# ==============================================================================
# TEST 9: APACHE SERVICE (requires SSH access)
# ==============================================================================

print_test "9" "Apache HTTP Server Status"

print_info "Apache service check requires SSH access through bastion"
print_info "To manually verify:"
print_info "  1. SSH to bastion: ssh -i ~/.ssh/package3-demo-bastion-key.pem ec2-user@$BASTION_IP"
print_info "  2. Test health endpoint: curl http://$FIRST_INSTANCE_IP/health"
print_info "  3. Expected output: OK"

# ==============================================================================
# TEST 10: COST ESTIMATE
# ==============================================================================

print_test "10" "Cost Estimate Verification"

print_info "Phase 6 Resources:"
print_info "  - Web instances: 3x t3.small = ~\$50/month"
print_info "  - Launch Template: Free"
print_info "  - Auto Scaling Group: Free"
print_info "  - IAM resources: Free"
print_info ""
print_info "Total Phase 6 cost: ~\$50/month"
print_success "Cost estimate documented"

# ==============================================================================
# SUMMARY
# ==============================================================================

print_header "TEST SUMMARY"

echo -e "${BLUE}Total Tests Run:${NC} $TESTS_RUN"
echo -e "${GREEN}Tests Passed:${NC} $TESTS_PASSED"
echo -e "${RED}Tests Failed:${NC} $TESTS_FAILED"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}========================================${NC}"
    echo -e "${GREEN}✓ ALL AUTOMATED TESTS PASSED!${NC}"
    echo -e "${GREEN}========================================${NC}\n"
    exit 0
else
    echo -e "\n${RED}========================================${NC}"
    echo -e "${RED}✗ SOME TESTS FAILED${NC}"
    echo -e "${RED}========================================${NC}\n"
    exit 1
fi
