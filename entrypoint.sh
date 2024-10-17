#!/bin/sh
set -e

name=$1
namespace=$2
log_level=$3
remove_volumes=$4  # New parameter for remove volumes

params=""
if [ ! -z "$namespace" ]; then
    params="--namespace=$namespace"
fi

if [ ! -z "$OKTETO_CA_CERT" ]; then
    echo "Custom certificate is provided"
    echo "$OKTETO_CA_CERT" > /usr/local/share/ca-certificates/okteto_ca_cert.crt
    update-ca-certificates
fi

if [ ! -z "$log_level" ]; then
    log_level="--log-level ${log_level}"
fi

# https://docs.github.com/en/actions/monitoring-and-troubleshooting-workflows/enabling-debug-logging
# https://docs.github.com/en/actions/learn-github-actions/variables#default-environment-variables
if [ "${RUNNER_DEBUG}" = "1" ]; then
    log_level="--log-level debug"
fi

# Check if remove volumes is set to true and add the -v flag
if [ "$remove_volumes" = "true" ]; then
    volume_flag="-v"
fi

echo running: okteto pipeline destroy $log_level --name "${name}" ${params} $volume_flag --wait
okteto pipeline destroy $log_level --name "${name}" ${params} $volume_flag --wait
