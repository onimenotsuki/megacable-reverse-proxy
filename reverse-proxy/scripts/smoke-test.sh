#!/usr/bin/env bash
# Smoke tests for the reverse proxy (HTTP paths + expected behavior).
# Run on a host that can reach the proxy (localhost on the node, or VIP/LB URL).
#
# Usage:
#   ./smoke-test.sh
#   BASE_URL=http://10.7.50.201 ./smoke-test.sh
#   BASE_URL=https://web.example.com EXTRA_HEADER='X-Forwarded-Proto: https' ./smoke-test.sh

set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1}"
VHOST="${VHOST:-web.xviewplusn2.com.mx}"
CURL_MAX_TIME="${CURL_MAX_TIME:-15}"

die() {
  echo "ERROR: $*" >&2
  exit 1
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "missing command: $1"
}

http_code() {
  local url="$1"
  local extra=()
  if [[ -n "${EXTRA_HEADER:-}" ]]; then
    extra+=(-H "${EXTRA_HEADER}")
  fi
  curl -sS -o /dev/null -w '%{http_code}' --max-time "${CURL_MAX_TIME}" \
    -H "Host: ${VHOST}" "${extra[@]}" "${url}" || echo "000"
}

expect_code() {
  local name="$1"
  local url="$2"
  local want="$3"
  local got
  got="$(http_code "${url}")"
  if [[ "${got}" == "${want}" ]]; then
    echo "OK   ${name} (${got}) ${url}"
  else
    echo "FAIL ${name}: want HTTP ${want}, got ${got} — ${url}" >&2
    return 1
  fi
}

expect_not_gateway() {
  local name="$1"
  local url="$2"
  local got
  got="$(http_code "${url}")"
  case "${got}" in
    502|503|504|000)
      echo "FAIL ${name}: upstream/proxy issue (HTTP ${got}) — ${url}" >&2
      return 1
      ;;
    *)
      echo "OK   ${name} (${got}) ${url}"
      ;;
  esac
}

main() {
  need_cmd curl

  echo "== Reverse proxy smoke tests =="
  echo "BASE_URL=${BASE_URL}"
  echo "Host header: ${VHOST}"
  echo

  local failed=0

  # BFF health endpoints (documented in README)
  expect_code "bff_linear is_alive" "${BASE_URL}/rtvbff/linear/is_alive" "200" || failed=1
  expect_code "bff_vod is_alive" "${BASE_URL}/rtvbff/vod/is_alive" "200" || failed=1
  expect_code "bff_image is_alive" "${BASE_URL}/rtvbff/image/is_alive" "200" || failed=1

  # SQUID-backed routes: accept any non-gateway response if path is routed
  expect_not_gateway "squid search" "${BASE_URL}/search" || failed=1
  expect_not_gateway "squid RTEFacade" "${BASE_URL}/RTEFacade" || failed=1

  # Unknown path must hit nginx default 404
  expect_code "default 404" "${BASE_URL}/__smoke_should_404__" "404" || failed=1

  echo
  if [[ "${failed}" -eq 0 ]]; then
    echo "All smoke checks passed."
    exit 0
  fi
  echo "Some checks failed (see above)." >&2
  exit 1
}

main "$@"
