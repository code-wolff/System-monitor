set -e

source ~/devops-journey/projects/system-monitor/config/monitor.conf

REF='\033[0;31m'
GREEN='\033[0;032m'
YELLOW='\033[1;33m'
NC='\033[0m'


log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a $LOG_FILE
}

# Alert function
alert() {
    LEVEL=$1
    MESSAGE=$2
    if [ "$LEVEL" = "CRITICAL" ]; then
        echo -e "${RED}[CRITICAL] $MESSAGE${NC}"
        log "CRITICAL: $MESSAGE"
    elif [ "$LEVEL" = "WARNING" ]; then
        echo -e "${YELLOW}[WARNING] $MESSAGE${NC}"
        log "WARNING: $MESSAGE"
    else
        echo -e "${GREEN}[OK] $MESSAGE${NC}"
        log "OK: $MESSAGE"
    fi
}


# ==========================================
# CHECK FUNCTIONS
# ==========================================

check_disk() {
    log "Checking disk usage..."
    DISK_USAGE=$(df -h / | awk 'NR==2{print $5}' | sed 's/%//')

    if [ "$DISK_USAGE" -ge "$DISK_THRESHOLD" ]; then
        alert "CRITICAL" "Disk usage is ${DISK_USAGE}% (threshold: ${DISK_THRESHOLD}%)"
    elif [ "$DISK_USAGE" -ge $((DISK_THRESHOLD - 10)) ]; then
        alert "WARNING" "Disk usage is ${DISK_USAGE}% (threshold: ${DISK_THRESHOLD}%)"
    else
        alert "OK" "Disk usage is ${DISK_USAGE}%"
    fi
}

check_memory() {
    log "Checking memory usage..."
    MEMORY_USAGE=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')

    if [ "$MEMORY_USAGE" -ge "$MEMORY_THRESHOLD" ]; then
        alert "CRITICAL" "Memory usage is ${MEMORY_USAGE}% (threshold: ${MEMORY_THRESHOLD}%)"
    elif [ "$MEMORY_USAGE" -ge $((MEMORY_THRESHOLD - 10)) ]; then
        alert "WARNING" "Memory usage is ${MEMORY_USAGE}% (threshold: ${MEMORY_THRESHOLD}%)"
    else
        alert "OK" "Memory usage is ${MEMORY_USAGE}%"
    fi
}

check_services() {
    log "Checking services..."
    for SERVICE in "${SERVICES[@]}"
    do
        if systemctl is-active --quiet $SERVICE; then
            alert "OK" "Service $SERVICE is running"
        else
            alert "CRITICAL" "Service $SERVICE is NOT running!"
        fi
    done
}


# ==========================================
# MAIN
# ==========================================

main() {
    echo ""
    echo "=========================================="
    echo "   System Health Monitor v1.0"
    echo "   $(date '+%Y-%m-%d %H:%M:%S')"
    echo "   Host: $(hostname)"
    echo "=========================================="
    echo ""

    log "=== Health Check Started ==="

    check_disk
    echo ""
    check_memory
    echo ""
    check_services
    echo ""

    log "=== Health Check Complete ==="
    echo ""
    echo "Log saved at: $LOG_FILE"
    echo ""
}

# Run main
main
