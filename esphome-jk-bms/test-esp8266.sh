#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
COMPONENTS_PATH="${REPO_ROOT}/components"

esphome -s external_components_source "${COMPONENTS_PATH}" "${1:-run}" "${2:-esp8266-example-faker.yaml}"
