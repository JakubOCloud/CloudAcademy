#!/usr/bin/env bash

set -euo pipefail

# Defaults

SERVICE=""
PORT=""
HEALTH=""
MODE=""
WAIT_TIME=10

# Log

log_info() {
    echo "[INFO] $1"
}

log_warn() {
    echo "[WARNING] $1"
}

log_error() {
    echo "[ERROR] $1"
}

# Usage

usage() {

cat <<EOF

Usage:

./self-heal.sh \
  --service <service> \
  --port <port> \
  --health-url <url> \
  --mode <check|heal|diagnose> \
  [--wait seconds]

Example:

./self-heal.sh \
  --service payment-api \
  --port 8080 \
  --health-url http://localhost:8080/health \
  --mode heal
  --wait 10

EOF

}

# Parse arguments

while [[ $# -gt 0 ]]
do
    case "$1" in

        --service)
            SERVICE="$2"
            shift 2
            ;;

        --port)
            PORT="$2"
            shift 2
            ;;

        --health-url)
            HEALTH_URL="$2"
            shift 2
            ;;

        --mode)
            MODE="$2"
            shift 2
            ;;

        --wait)
            WAIT_TIME="$2"
            shift 2
            ;;

        *)
            log_error "Unknown argument: $1"
            usage
            exit 2
            ;;

    esac
done

# Validate arguments

if [[ -z "$SERVICE" ||
      -z "$PORT" ||
      -z "$HEALTH_URL" ||
      -z "$MODE" ]]
then

    log_error "Missing required arguments"

    usage

    exit 2
fi

# Check mode

case "$MODE" in
    check|heal|diagnose)
        ;;
    *)
        log_error "Invalid mode: $MODE"
        usage
        exit 2
        ;;
esac

# Checking dependencies

check_dependencies() {

    local tools=(
        systemctl
        curl
        ss
    )

    for tool in "${tools[@]}"
    do
        if ! command -v "$tool" >/dev/null 2>&1
        then
            log_error "$tool is not installed"
            exit 2
        fi
    done

}

# Service check

check_service() {

    log_info "Checking service: $SERVICE"

    if systemctl is-active --quiet "$SERVICE"; then
        log_info "Service is active"
        return 0
    else
        log_error "Service is not active"
        return 1
    fi
}

# Port check

check_port() {

    log_info "Checking port: $PORT"

    if ss -ltn | grep -q ":$PORT "; then
        log_info "Port $PORT is listening"
        return 0
    else
        log_error "Port $PORT is not listening"
        return 1
    fi
}

# Health check

check_health() {

    log_info "Checking health endpoint"

    response=$(curl -s --max-time 5 "$HEALTH_URL")

    if echo "$response" | grep -q '"status":"UP"'; then
        log_info "Health endpoint is healthy"
        return 0
    else
        log_error "Health endpoint is unhealthy"
        return 1
    fi
}

# Check mode

perform_check() {

    check_service || return 1
    check_port || return 1
    check_health || return 1

    log_info "Service is healthy"

    return 0
}

check_dependencies

case "$MODE" in

    check)

        if perform_check; then
            exit 0
        else
            exit 1
        fi
        ;;

    heal)
        log_info "Heal mode not implemented yet"
        ;;

    diagnose)
        log_info "Diagnose mode not implemented yet"
        ;;

esac
