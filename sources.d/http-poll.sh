#!/bin/bash
# http-poll.sh — Poll a URL until the response matches a condition.
#
# Useful for waiting on:
#   - A service to become healthy (/health returns 200)
#   - A deploy to finish (status API returns "complete")
#   - A resource to appear (GET returns 200 instead of 404)
#   - A value to change (response body contains a string)
#
# Args: <url> [expected_status=200] [body_contains=] [interval=2] [timeout=300]
#
# Event Source Protocol:
#   Polls the URL every <interval> seconds.
#   Blocks until the response matches the expected status AND (if specified)
#   the body contains the expected string, OR timeout is reached.
#   Outputs the matching response body to stdout.
#   Exit code 0 = matched, 1 = timed out.

set -euo pipefail

URL="${1:?Usage: http-poll.sh <url> [expected_status=200] [body_contains=] [interval=2] [timeout=300]}"
EXPECTED_STATUS="${2:-200}"
BODY_CONTAINS="${3:-}"
INTERVAL="${4:-2}"
TIMEOUT="${5:-300}"

STARTED=$(date +%s)

while true; do
  ELAPSED=$(( $(date +%s) - STARTED ))
  if [ "$ELAPSED" -ge "$TIMEOUT" ]; then
    echo "TIMEOUT after ${ELAPSED}s polling $URL (expected status=$EXPECTED_STATUS${BODY_CONTAINS:+, body contains=\"$BODY_CONTAINS\"})"
    exit 1
  fi

  RESPONSE=$(curl -s -w "\n%{http_code}" --connect-timeout 5 --max-time 10 "$URL" 2>/dev/null) || {
    sleep "$INTERVAL"
    continue
  }

  HTTP_CODE=$(echo "$RESPONSE" | tail -1)
  BODY=$(echo "$RESPONSE" | sed '$d')

  if [ "$HTTP_CODE" = "$EXPECTED_STATUS" ]; then
    if [ -z "$BODY_CONTAINS" ] || echo "$BODY" | grep -q "$BODY_CONTAINS"; then
      echo "$BODY"
      exit 0
    fi
  fi

  sleep "$INTERVAL"
done
