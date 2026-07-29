#!/bin/bash

set -e

SERVICE=""
VERSION=""
HEALTH_URL=""
DELAY=""
MAX_RETRIES=3

# Parsing arguments

while [[ $# -gt 0 ]]; do
    case $1 in
        --service)
            SERVICE="$2"
            shift 2
            ;;
        --version)
            VERSION="$2"
            shift 2
            ;;
        --health-url)
            HEALTH_URL="$2"
            shift 2
            ;;
        --delay)
            DELAY="$2"
            shift 2
            ;;
        --retries)
            MAX_RETRIES="$2"
            shift 2
            ;;
        *)
            log_error "Unknown argument: $1"
            echo "bash deploy-guard.sh --service NAME --version VERSION --health-url URL --delay SECONDS [--retries N]"
            exit 2
            ;;
    esac
done

# Checking required arguments

if [[ -z "$SERVICE" || -z "$VERSION" || -z "$HEALTH_URL" || -z "$DELAY" ]]; then
    echo "Usage:"
    echo "bash deploy-guard.sh --service NAME --version VERSION --health-url URL --delay SECONDS [--retries N]"
    exit 2
fi

# Logs

log_info() {
    echo "[INFO] $1"
}

log_warning() {
    echo "[WARNING] $1"
}

log_error() {
    echo "[ERROR] $1"
}

# Version read

CURRENT_VERSION=$(cat state/current_version)
ROLLBACK_VERSION=$CURRENT_VERSION

log_info "Starting deployment for $SERVICE version $VERSION"

# Health check

health_check() {

    for ((i=1; i<=MAX_RETRIES; i++)); do

        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$HEALTH_URL")

        if [[ "$HTTP_CODE" == "200" ]]; then

            BODY=$(curl -s "$HEALTH_URL")

            if echo "$BODY" | grep -q "UP"; then
                return 0
            fi
        fi

        log_warning "Health check failed (attempt $i/$MAX_RETRIES)"
        sleep 1

    done

    return 1
}

# Rollback

rollback() {

    log_warning "Rolling back deployment"

    bash stop_service.sh

    bash start_service.sh "$ROLLBACK_VERSION"

    echo "$ROLLBACK_VERSION" > state/current_version

    for instance in state/instances/*.version; do
        echo "$ROLLBACK_VERSION" > "$instance"
    done

    log_info "Rollback successful"

    exit 1
}

for instance in state/instances/*.version; do

    log_info "Deploying to $(basename "$instance" .version)"

    echo "$VERSION" > "$instance"

    bash stop_service.sh
    bash start_service.sh "$VERSION"

    log_info "Waiting $DELAY seconds"

    sleep "$DELAY"

    if health_check; then
        log_info "Health check passed"
    else
        log_error "Health check failed"
        rollback
    fi

done

echo "$VERSION" > state/current_version

log_info "Deployment completed successfully"

exit 0