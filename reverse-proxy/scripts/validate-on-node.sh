#!/usr/bin/env bash
# Run on the Nginx node (201/202) after deploy: syntax, systemd, quick HTTP checks.
# Requires: nginx binary, systemctl, curl; sudo for nginx -t / systemctl if non-root.
#
# Usage:
#   ./validate-on-node.sh
#   CONFIG=/etc/megacable-reverse-proxy/nginx.conf ./validate-on-node.sh

set -euo pipefail

CONFIG="${CONFIG:-/etc/megacable-reverse-proxy/nginx.conf}"
SERVICE="${SERVICE:-megacable-reverse-proxy}"
VHOST="${VHOST:-web.xviewplusn2.com.mx}"
BASE_URL="${BASE_URL:-http://127.0.0.1}"

die() {
  echo "ERROR: $*" >&2
  exit 1
}

run_sudo() {
  if [[ "$(id -u)" -eq 0 ]]; then
    "$@"
  else
    sudo "$@"
  fi
}

main() {
  echo "== Validate reverse proxy on node =="
  echo "CONFIG=${CONFIG}"
  echo "SERVICE=${SERVICE}"
  echo

  command -v nginx >/dev/null 2>&1 || die "nginx not found in PATH"
  command -v systemctl >/dev/null 2>&1 || die "systemctl not found"
  command -v curl >/dev/null 2>&1 || die "curl not found"

  echo "-- nginx -t --"
  run_sudo nginx -t -c "${CONFIG}"
  echo

  echo "-- systemctl is-active --"
  state="$(run_sudo systemctl is-active "${SERVICE}")"
  [[ "${state}" == "active" ]] || die "service ${SERVICE} is not active (got: ${state})"
  echo "${SERVICE}: ${state}"
  echo

  echo "-- HTTP smoke (same as scripts/smoke-test.sh) --"
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  export BASE_URL VHOST
  bash "${SCRIPT_DIR}/smoke-test.sh"
}

main "$@"
