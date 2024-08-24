#!/bin/bash

# Interval in seconds for refreshing the dashboard
INTERVAL=5

# Function to display the top 10 most used applications by CPU and memory
show_top_apps() {
    echo "### Top 10 Most Used Applications ###"
    ps aux --sort=-%cpu,-%mem | awk 'NR<=10{printf "%-10s %-10s %-10s %-10s %-10s\n", $1, $2, $3, $4, $11}' | head -n 11
}

# Function to display network monitoring stats
show_network_stats() {
    echo "### Network Monitoring ###"
    echo "Concurrent connections: $(ss -s | grep -oP 'TCP:\s+\K(\d+)')"
    echo "Packet drops:"
    netstat -i | awk '/Iface/ {getline; print}'
    echo "Network I/O:"
    ifstat -t 1 1 | tail -n 1
}

# Function to display disk usage
show_disk_usage() {
    echo "### Disk Usage ###"
    df -h | awk '$5 >= 80 || NR == 1 {print $0}'
}

# Function to display system load
show_system_load() {
    echo "### System Load ###"
    echo "Load Average: $(uptime | awk -F 'load average: ' '{print $2}')"
    echo "CPU Breakdown:"
    mpstat | grep -A 5 "%idle" | tail -n 5
}

# Function to display memory usage
show_memory_usage() {
    echo "### Memory Usage ###"
    free -h
    echo "Swap Memory Usage:"
    swapon --show
}

# Function to display process monitoring stats
show_process_stats() {
    echo "### Process Monitoring ###"
    echo "Active Processes: $(ps aux | wc -l)"
    echo "Top 5 Processes by CPU and Memory:"
    ps aux --sort=-%cpu,-%mem | awk 'NR<=5{printf "%-10s %-10s %-10s %-10s %-10s\n", $1, $2, $3, $4, $11}' | head -n 6
}

# Function to display service monitoring
show_service_monitoring() {
    echo "### Service Monitoring ###"
    for service in sshd nginx apache2 iptables; do
        if systemctl is-active --quiet $service; then
            echo "$service: Active"
        else
            echo "$service: Inactive"
        fi
    done
}

# Main dashboard function
show_dashboard() {
    clear
    echo "### Custom System Dashboard ###"
    echo
    show_top_apps
    echo
    show_network_stats
    echo
    show_disk_usage
    echo
    show_system_load
    echo
    show_memory_usage
    echo
    show_process_stats
    echo
    show_service_monitoring
}

# Main script execution
while [[ $# -gt 0 ]]; do
    case $1 in
        -cpu)
            show_top_apps
            exit 0
            ;;
        -memory)
            show_memory_usage
            exit 0
            ;;
        -network)
            show_network_stats
            exit 0
            ;;
        -disk)
            show_disk_usage
            exit 0
            ;;
        -load)
            show_system_load
            exit 0
            ;;
        -processes)
            show_process_stats
            exit 0
            ;;
        -services)
            show_service_monitoring
            exit 0
            ;;
        *)
            echo "Usage: $0 [-cpu] [-memory] [-network] [-disk] [-load] [-processes] [-services]"
            exit 1
            ;;
    esac
done

# Default to showing the full dashboard with automatic refresh
while true; do
    show_dashboard
    sleep $INTERVAL
done
