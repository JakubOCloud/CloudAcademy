#!/usr/bin/env bash

set -euo pipefail

SERVICE=""
PORT=""
HEALTH=""
MODE=""
WAIT_TIME=10

log_info() {
    echo "[INFO] $1"
}

log_warn() {
    echo "[WARNING] $1"
}

log_error() {
    echo "[ERROR] $1"
}

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