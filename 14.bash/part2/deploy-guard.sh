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
            echo "Unknown argument: $1"
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

# test

echo "Service: $SERVICE"
echo "Version: $VERSION"
echo "Health URL: $HEALTH_URL"
echo "Delay: $DELAY"
echo "Retries: $MAX_RETRIES"