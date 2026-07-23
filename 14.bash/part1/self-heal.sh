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