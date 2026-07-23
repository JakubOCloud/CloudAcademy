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