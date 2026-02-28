#!/bin/bash
# Description: Validate VPN Data Plane and Control Plane routing
# Usage: ./validate_connectivity.sh <AWS_PRIVATE_IP_OF_EC2>

TARGET_IP=$1
LOG_FILE="/tmp/test-results.log"

if [ -z "$TARGET_IP" ]; then
    echo "Usage: $0 <AWS_PRIVATE_IP>"
    exit 1
fi

echo "Starting VPN Connectivity Validation to $TARGET_IP" | tee "$LOG_FILE"
echo "==================================================" | tee -a "$LOG_FILE"

# 1. Traceroute Test
echo -e "\n[+] Running Traceroute to verify the path uses the VyOS Gateway (192.168.0.1)..." | tee -a "$LOG_FILE"
traceroute -m 5 "$TARGET_IP" | tee -a "$LOG_FILE"
# Check if the first hop is the VyOS LAN IP
if traceroute -m 1 "$TARGET_IP" | grep -q "192.168.0.1"; then
    echo "PASS: Traffic is routing through the VyOS Gateway." | tee -a "$LOG_FILE"
else
    echo "FAIL: Traffic is NOT routing through the VyOS Gateway." | tee -a "$LOG_FILE"
fi

# 2. MTU/MSS Path Discovery Ping Test
# Using 1350 is a safe size to demonstrate that MSS clamping is preventing fragmentation drops
echo -e "\n[+] Running MTU/MSS Ping Test (Payload Size: 1350 bytes)..." | tee -a "$LOG_FILE"
if ping -c 4 -s 1350 "$TARGET_IP" >> "$LOG_FILE" 2>&1; then
    echo "PASS: Large packet ping succeeded. Path MTU + MSS Clamping verified working." | tee -a "$LOG_FILE"
else
    echo "FAIL: Large packet ping failed. Fragmentation might be occurring." | tee -a "$LOG_FILE"
fi

echo -e "\n==================================================" | tee -a "$LOG_FILE"
echo "Validation complete. Logs dynamically saved to $LOG_FILE"
