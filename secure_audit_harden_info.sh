#!/bin/bash

### 1. User and Group Audits ###
echo "### User and Group Audits ###"
# List all users and groups
getent passwd
getent group
# Check for UID 0 users
echo "Non-standard UID 0 users:"
awk -F: '($3 == 0) {print}' /etc/passwd
# Check for users without passwords
echo "Users without passwords:"
awk -F: '($2 == "" || $2 == "!") {print $1}' /etc/shadow

### 2. File and Directory Permissions ###
echo "### File and Directory Permissions ###"
# World-writable files
echo "World-writable files:"
find / -type f -perm -o+w 2>/dev/null
# .ssh directory check
echo ".ssh directory permissions:"
find / -type d -name ".ssh" -exec ls -ld {} \;
# SUID/SGID files
echo "SUID/SGID files:"
find / -perm /6000 -type f 2>/dev/null

### 3. Service Audits ###
echo "### Service Audits ###"
# List all services
echo "Running services:"
systemctl list-units --type=service --state=running
# Check critical services
echo "Checking critical services:"
for service in sshd iptables; do
    systemctl is-active --quiet $service && echo "$service is running" || echo "$service is not running"
done
# Check open ports
echo "Open ports and services:"
ss -tuln

### 4. Firewall and Network Security ###
echo "### Firewall and Network Security ###"
# Check firewall status
echo "Firewall status:"
systemctl status firewalld || systemctl status iptables
# IP forwarding
echo "IP forwarding settings:"
sysctl net.ipv4.ip_forward net.ipv6.conf.all.forwarding

### 5. IP and Network Configuration Checks ###
echo "### IP and Network Configuration Checks ###"
# Public vs Private IPs
echo "Public vs Private IPs:"
ip a
echo "Public IP:"
curl -s ifconfig.me
# Sensitive services exposure
echo "Checking SSH service exposure:"
ss -tuln | grep ":22"

### 6. Security Updates and Patching ###
echo "### Security Updates and Patching ###"
# Check for updates
echo "Available updates:"
dnf check-update
# Ensure automatic updates
echo "Checking automatic updates configuration:"
systemctl status dnf-automatic.timer

### 7. Log Monitoring ###
echo "### Log Monitoring ###"
# Check for suspicious log entries
echo "Suspicious SSH log entries:"
grep "Failed password" /var/log/secure

### 8. Server Hardening Steps ###
echo "### Server Hardening Steps ###"
# SSH Configuration
echo "Configuring SSH for key-based authentication:"
sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl reload sshd
# Disable IPv6
echo "Disabling IPv6:"
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1
# Secure GRUB bootloader
echo "Securing GRUB bootloader:"
grub2-setpassword
# Firewall configuration
echo "Configuring iptables:"
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables-save > /etc/sysconfig/iptables

### 9. Custom Security Checks ###
echo "### Custom Security Checks ###"
# Include custom checks from a config file
if [ -f /etc/secure_audit_harden/custom_checks.conf ]; then
    source /etc/secure_audit_harden/custom_checks.conf
fi

### 10. Reporting and Alerting ###
echo "### Reporting and Alerting ###"
# Generate a summary report
report="/var/log/secure_audit_report.log"
echo "Security Audit Report - $(date)" > $report
echo "User and Group Audits:" >> $report
awk -F: '($3 == 0) {print}' /etc/passwd >> $report
awk -F: '($2 == "" || $2 == "!") {print $1}' /etc/shadow >> $report
echo "World-writable files:" >> $report
find / -type f -perm -o+w 2>/dev/null >> $report
echo "Open ports:" >> $report
ss -tuln >> $report
echo "Suspicious SSH log entries:" >> $report
grep "Failed password" /var/log/secure >> $report
echo "Firewall status:" >> $report
systemctl status firewalld || systemctl status iptables >> $report

# Email report if critical issues found
if grep -q "FAILED" $report; then
    mail -s "Critical Security Issues Found" admin@example.com < $report
fi

echo "Security audit and hardening completed. Report saved to $report"
