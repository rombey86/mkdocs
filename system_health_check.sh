#!/bin/bash
# System Health Check Script
# Created by Tobias and Claw for practical testing of self-sufficient automation
# Version: 0.1.0
# Designed to run independently without AI dependencies

# Configuration - easy to modify
THRESHOLD_CPU_WARNING=80
THRESHOLD_CPU_CRITICAL=95
THRESHOLD_MEMORY_WARNING=80
THRESHOLD_MEMORY_CRITICAL=95
THRESHOLD_DISK_WARNING=85
THRESHOLD_DISK_CRITICAL=95
LOG_FILE="/var/log/system_health_check.log"
ALERT_EMAIL=""  # Leave empty for console only, or set email address

# Colors for output (optional)
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Logging function
log_message() {
    local message="$1"
    local level="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    
    # Also output to console if not running as daemon
    if [ -t 1 ]; then
        case "$level" in
            "WARN") echo -e "${YELLOW}[WARN]${NC} $message" ;;
            "CRIT") echo -e "${RED}[CRIT]${NC} $message" ;;
            "INFO") echo -e "${GREEN}[INFO]${NC} $message" ;;
            *) echo "$message" ;;
        esac
    fi
}

# Check CPU usage
check_cpu() {
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    local cpu_int=${cpu_usage%.*}  # Get integer part
    
    if [ "$cpu_int" -ge "$THRESHOLD_CPU_CRITICAL" ]; then
        log_message "CPU usage critical: ${cpu_usage}%" "CRIT"
        return 2
    elif [ "$cpu_int" -ge "$THRESHOLD_CPU_WARNING" ]; then
        log_message "CPU usage warning: ${cpu_usage}%" "WARN"
        return 1
    else
        log_message "CPU usage OK: ${cpu_usage}%" "INFO"
        return 0
    fi
}

# Check memory usage
check_memory() {
    local memory_usage=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
    local memory_int=${memory_usage%.*}
    
    if [ "$memory_int" -ge "$THRESHOLD_MEMORY_CRITICAL" ]; then
        log_message "Memory usage critical: ${memory_usage}%" "CRIT"
        return 2
    elif [ "$memory_int" -ge "$THRESHOLD_MEMORY_WARNING" ]; then
        log_message "Memory usage warning: ${memory_usage}%" "WARN"
        return 1
    else
        log_message "Memory usage OK: ${memory_usage}%" "INFO"
        return 0
    fi
}

# Check disk usage for root partition
check_disk() {
    local disk_usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    
    if [ "$disk_usage" -ge "$THRESHOLD_DISK_CRITICAL" ]; then
        log_message "Disk usage critical: ${disk_usage}%" "CRIT"
        return 2
    elif [ "$disk_usage" -ge "$THRESHOLD_DISK_WARNING" ]; then
        log_message "Disk usage warning: ${disk_usage}%" "WARN"
        return 1
    else
        log_message "Disk usage OK: ${disk_usage}%" "INFO"
        return 0
    fi
}

# Check essential services
check_services() {
    local services=("ssh" "cron" "systemd-logind")
    local failed=0
    
    for service in "${services[@]}"; do
        if ! systemctl is-active --quiet "$service" 2>/dev/null; then
            log_message "Service $service is not active" "WARN"
            ((failed++))
        fi
    done
    
    if [ "$failed" -gt 0 ]; then
        log_message "$failed service(s) not active" "WARN"
        return 1
    else
        log_message "All essential services active" "INFO"
        return 0
    fi
}

# Main execution
main() {
    log_message "Starting system health check" "INFO"
    
    # Run all checks
    check_cpu
    local cpu_status=$?
    
    check_memory
    local mem_status=$?
    
    check_disk
    local disk_status=$?
    
    check_services
    local svc_status=$?
    
    # Determine overall status
    local max_status=0
    for status in $cpu_status $mem_status $disk_status $svc_status; do
        if [ "$status" -gt "$max_status" ]; then
            max_status=$status
        fi
    done
    
    case "$max_status" in
        0) log_message "All systems OK" "INFO";;
        1) log_message "One or more warnings detected" "WARN";;
        2) log_message "Critical issues detected" "CRIT";;
    esac
    
    log_message "System health check completed" "INFO"
    return $max_status
}

# Execute main function
main "$@"
exit $?