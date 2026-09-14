#!/usr/bin/env bash
# -----------------------------------------------------------------
# @title        Task4_return_codes_error_handling.sh
# @author       Agnes Yeboah
# @index        5230160043
# @school       University of Skills Training and Entrepreneurial Development (USTED)
# @description  Runs a sequence of system checks with disciplined
#               exit-code handling and documented exit codes.
# @date         2026-09-14
# -----------------------------------------------------------------
#
# Exit codes:
#   0 = all checks passed
#   1 = missing required argument
#   2 = host unreachable
#   3 = insufficient disk space
#   4 = required file not found
#   5 = required command not found
# -----------------------------------------------------------------

usage() {
  echo "Usage: $0 <hostname>"
  echo "  <hostname>  a host to test connectivity against (e.g. google.com)"
  exit 1
}

if [[ "$1" == "-h" || "$1" == "--help" || -z "$1" ]]; then
  usage
fi

HOSTNAME_ARG="$1"


# ---------------------------------------------------------
# A temporary file used during the disk-space check below.
# We declare it here so the trap (cleanup) can reference it
# no matter which check we're on when the script exits.
# ---------------------------------------------------------
TMP_FILE=$(mktemp)

# ---------------------------------------------------------
# Cleanup function: removes the temp file. Registered with
# trap so it runs automatically on normal exit, on failure,
# or if the user interrupts the script with Ctrl+C (SIGINT).
# ---------------------------------------------------------
cleanup() {
  rm -f "$TMP_FILE"
  echo "Cleaned up temporary files."
}
trap cleanup EXIT

# ---------------------------------------------------------
# check_status: takes an exit code, a description, and the
# specific exit code to use if this check failed. Logs a
# pass/fail message and exits immediately on failure - this
# is the "disciplined exit-code handling" the task requires.
# ---------------------------------------------------------
check_status() {
  local result="$1"
  local description="$2"
  local fail_exit_code="$3"

  if [ "$result" -eq 0 ]; then
    echo "[PASS] $description"
  else
    echo "[FAIL] $description" >&2
    exit "$fail_exit_code"
  fi
}


# ---------------------------------------------------------
# Check 1: Is the given host reachable?
# ping -c 1 sends a single packet; -W 2 waits max 2 seconds
# for a reply. We don't want the script hanging indefinitely
# on an unreachable host.
# ---------------------------------------------------------
ping -c 1 -W 2 "$HOSTNAME_ARG" > "$TMP_FILE" 2>&1
check_status "$?" "Reachability check for host '$HOSTNAME_ARG'" 2


# ---------------------------------------------------------
# Check 2: Is there enough free disk space?
# df --output=avail gives available space in KB for the
# filesystem containing "/". We check if it's above a
# minimum threshold (here, 1GB = 1048576 KB) as an example.
# ---------------------------------------------------------
AVAILABLE_KB=$(df --output=avail / | tail -n 1 | tr -d ' ')
MIN_REQUIRED_KB=1048576

if [ "$AVAILABLE_KB" -ge "$MIN_REQUIRED_KB" ]; then
  DISK_CHECK_RESULT=0
else
  DISK_CHECK_RESULT=1
fi

check_status "$DISK_CHECK_RESULT" "At least 1GB free disk space on /" 3


# ---------------------------------------------------------
# Check 3: Does a required config/data file exist and is it readable?
# We check against /etc/hosts here as an example of a file that
# should always exist on a Linux system.
# ---------------------------------------------------------
REQUIRED_FILE="/etc/hosts"

if [ -f "$REQUIRED_FILE" ] && [ -r "$REQUIRED_FILE" ]; then
  FILE_CHECK_RESULT=0
else
  FILE_CHECK_RESULT=1
fi

check_status "$FILE_CHECK_RESULT" "Required file '$REQUIRED_FILE' exists and is readable" 4


# ---------------------------------------------------------
# Check 4: Is a required command/tool installed?
# command -v prints the path to a command if it exists,
# and produces no output (with a non-zero exit code) if not.
# We check for curl here as an example commonly-needed tool.
# ---------------------------------------------------------
REQUIRED_CMD="curl"

command -v "$REQUIRED_CMD" > "$TMP_FILE" 2>&1
check_status "$?" "Required command '$REQUIRED_CMD' is installed" 5

echo "All checks completed successfully."
exit 0
