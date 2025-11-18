#!/bin/bash
# ==============================================================================
# PHASE 7 - WEB ALB QUICK TESTS
# ==============================================================================

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=========================================="
echo "Phase 7: Web ALB Tests"
echo "=========================================="

# Get ALB DNS
echo ""
echo -e "${YELLOW}Getting ALB DNS name...${NC}"
ALB_DNS=$(terraform output -raw web_alb_dns_name 2>/dev/null)

if [ -z "$ALB_DNS" ]; then
    echo -e "${RED}✗ FAIL: Could not get ALB DNS name${NC}"
    exit 1
fi

echo -e "${GREEN}✓ ALB DNS: $ALB_DNS${NC}"

# Test 1: Health Check Endpoint
echo ""
echo -e "${YELLOW}TEST 1: Health Check Endpoint${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://$ALB_DNS/health)

if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✓ PASS: Health endpoint returned 200${NC}"
else
    echo -e "${RED}✗ FAIL: Health endpoint returned $HTTP_CODE${NC}"
fi

# Test 2: Main Page
echo ""
echo -e "${YELLOW}TEST 2: Main Page${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://$ALB_DNS/)

if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✓ PASS: Main page returned 200${NC}"
else
    echo -e "${RED}✗ FAIL: Main page returned $HTTP_CODE${NC}"
fi

# Test 3: Target Health
echo ""
echo -e "${YELLOW}TEST 3: Target Group Health${NC}"
TG_ARN=$(terraform output -raw web_target_group_arn 2>/dev/null)

if [ -n "$TG_ARN" ]; then
    HEALTHY_COUNT=$(aws elbv2 describe-target-health \
        --target-group-arn "$TG_ARN" \
        --region ap-southeast-1 \
        --query 'TargetHealthDescriptions[?TargetHealth.State==`healthy`] | length(@)' \
        --output text 2>/dev/null)
    
    TOTAL_COUNT=$(aws elbv2 describe-target-health \
        --target-group-arn "$TG_ARN" \
        --region ap-southeast-1 \
        --query 'TargetHealthDescriptions | length(@)' \
        --output text 2>/dev/null)
    
    echo "Healthy targets: $HEALTHY_COUNT / $TOTAL_COUNT"
    
    if [ "$HEALTHY_COUNT" -ge 2 ]; then
        echo -e "${GREEN}✓ PASS: At least 2 targets are healthy${NC}"
    else
        echo -e "${RED}✗ FAIL: Less than 2 healthy targets${NC}"
    fi
fi

# Test 4: Load Distribution
echo ""
echo -e "${YELLOW}TEST 4: Load Distribution (5 requests)${NC}"
for i in {1..5}; do
    INSTANCE_ID=$(curl -s http://$ALB_DNS/ 2>/dev/null | grep -oP 'Instance ID:.*?<strong>\K[^<]+' || echo "N/A")
    echo "Request $i: Instance $INSTANCE_ID"
    sleep 1
done
echo -e "${GREEN}✓ Requests completed (check for distribution)${NC}"

# Test 5: Response Time
echo ""
echo -e "${YELLOW}TEST 5: Response Time${NC}"
RESPONSE_TIME=$(curl -o /dev/null -s -w "%{time_total}" http://$ALB_DNS/)
echo "Response time: ${RESPONSE_TIME}s"

if [ $(echo "$RESPONSE_TIME < 2.0" | bc -l) -eq 1 ]; then
    echo -e "${GREEN}✓ PASS: Response time under 2 seconds${NC}"
else
    echo -e "${YELLOW}⚠ WARNING: Response time over 2 seconds${NC}"
fi

# Summary
echo ""
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo -e "ALB URL: ${GREEN}http://$ALB_DNS${NC}"
echo ""
echo "Try these commands:"
echo "  curl http://$ALB_DNS/health"
echo "  curl http://$ALB_DNS/"
echo "  open http://$ALB_DNS/  # (opens in browser)"
echo ""
echo "=========================================="
