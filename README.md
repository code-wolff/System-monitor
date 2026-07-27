# System Health Monitor

A production-grade bash script to monitor system health.

## Author
Vivek Verma (code-wolff)

## Features
- Disk usage monitoring
- Memory usage monitoring
- Service status checking
- Timestamped logging
- Color-coded alerts (OK/WARNING/CRITICAL)

## Configuration
Edit `config/monitor.conf` to set thresholds:
- DISK_THRESHOLD (default: 80%)
- MEMORY_THRESHOLD (default: 85%)
- SERVICES to monitor

## Usage
```bash
chmod 755 monitor.sh
./monitor.sh
```

## Log Location
logs/monitor.log

## Tech Stack
- Bash scripting
- Linux system commands
- systemctl service management
