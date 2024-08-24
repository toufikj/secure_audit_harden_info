Secure Audit and Hardening Script
Overview

This Bash script automates security audits and hardening for Amazon Linux 2023 servers. It performs user and group audits, checks file permissions, audits services, verifies firewall and network security, and more. The script also includes customizable security checks and generates a detailed report.

Features
User and Group Audits: Lists all users, groups, and identifies non-standard root users.
File and Directory Permissions: Scans for world-writable files and SUID/SGID files.
Service Audits: Lists running services, ensures critical services are active, and checks open ports.
Firewall and Network Security: Verifies firewall status and checks for IP forwarding.
IP and Network Configuration Checks: Identifies public/private IPs and sensitive service exposure.
Security Updates and Patching: Reports available updates and ensures automatic updates are configured.
Log Monitoring: Checks for suspicious log entries.
Server Hardening Steps: Configures SSH, disables IPv6, secures the GRUB bootloader, and applies iptables rules.
Custom Security Checks: Supports custom checks via a configuration file.
Reporting and Alerting: Generates a summary report and optionally sends email alerts for critical issues.
Requirements
Amazon Linux 2023
Root privileges to execute the script
curl and mail utilities installed for reporting and IP identification

Usage
Clone the Repository:
git clone https://github.com/yourusername/secure-audit-harden.git
cd secure-audit-harden
Run the Script:
sudo ./secure_audit_harden.sh
Custom Checks: Add your custom checks to the configuration file located at:
/etc/secure_audit_harden/custom_checks.conf
View the Report: The audit report is saved to:
/var/log/secure_audit_report.log
Email Alerts: Configure the mail utility to receive alerts if critical issues are found.

Configuration
SSH Configuration: The script configures SSH to disable password-based logins for the root user.
Automatic Updates: Ensures the server is configured for automatic security updates.
