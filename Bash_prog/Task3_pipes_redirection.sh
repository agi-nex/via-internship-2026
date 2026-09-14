#!/usr/bin/env bash
# -----------------------------------------------------------------
# @title        Task3_pipes_redirection.sh
# @author       Agnes Yeboah
# @index        5230160043
# @school       University of Skills Training and Entrepreneurial Development (USTED)
# @description  Generates sample log data and uses pipes/text tools
#               to summarize log levels, top IPs, and error lines.
# @date         2026-09-13
# -----------------------------------------------------------------

usage() {
  echo "Usage: $0"
  echo "  This script takes no arguments. It generates its own sample"
  echo "  log data and produces a summary report in results.txt."
  exit 1
}

# This script takes no arguments, so if the user passes -h/--help
# or any unexpected argument, show usage instead of ignoring it silently.
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  usage
fi

LOG_FILE="sample_access.log"

# ---------------------------------------------------------
# Step 1: Generate sample log data using a heredoc.
# A heredoc (<< 'EOF' ... EOF) lets us write multiple lines
# of text directly into a file without needing external tools.
# Quoting 'EOF' prevents Bash from trying to expand anything
# inside (like $variables) - we want the literal text as-is.
# ---------------------------------------------------------
cat > "$LOG_FILE" << 'EOF'
2026-09-11 10:00:01 INFO 192.168.1.10 User login successful
2026-09-11 10:00:05 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:00:10 WARN 192.168.1.10 Disk usage above 80%
2026-09-11 10:00:15 INFO 192.168.1.15 User login successful
2026-09-11 10:00:20 ERROR 192.168.1.23 Database connection failed
2026-09-11 10:00:25 INFO 192.168.1.10 File uploaded successfully
2026-09-11 10:00:30 WARN 192.168.1.30 CPU usage above 90%
2026-09-11 10:00:35 ERROR 192.168.1.45 Authentication failed
2026-09-11 10:00:40 INFO 192.168.1.15 User logout
2026-09-11 10:00:45 INFO 192.168.1.10 User login successful
2026-09-11 10:00:50 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:00:55 WARN 192.168.1.10 Memory usage above 85%
2026-09-11 10:01:00 INFO 192.168.1.50 User login successful
2026-09-11 10:01:05 ERROR 192.168.1.45 Authentication failed
2026-09-11 10:01:10 INFO 192.168.1.15 User login successful
2026-09-11 10:01:15 WARN 192.168.1.30 Disk usage above 80%
2026-09-11 10:01:20 INFO 192.168.1.10 File downloaded successfully
2026-09-11 10:01:25 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:01:30 INFO 192.168.1.50 User logout
2026-09-11 10:01:35 WARN 192.168.1.10 CPU usage above 90%
2026-09-11 10:01:40 INFO 192.168.1.15 User login successful
2026-09-11 10:01:45 ERROR 192.168.1.45 Authentication failed
2026-09-11 10:01:50 INFO 192.168.1.10 User login successful
2026-09-11 10:01:55 WARN 192.168.1.30 Memory usage above 85%
2026-09-11 10:02:00 ERROR 192.168.1.23 Database connection failed
2026-09-11 10:02:05 INFO 192.168.1.50 User login successful
2026-09-11 10:02:10 INFO 192.168.1.15 File uploaded successfully
2026-09-11 10:02:15 WARN 192.168.1.10 Disk usage above 80%
2026-09-11 10:02:20 ERROR 192.168.1.45 Authentication failed
2026-09-11 10:02:25 INFO 192.168.1.10 User login successful
2026-09-11 10:02:30 INFO 192.168.1.15 User logout
2026-09-11 10:02:35 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:02:40 WARN 192.168.1.30 CPU usage above 90%
2026-09-11 10:02:45 INFO 192.168.1.50 User login successful
2026-09-11 10:02:50 INFO 192.168.1.10 File downloaded successfully
2026-09-11 10:02:55 ERROR 192.168.1.45 Authentication failed
2026-09-11 10:03:00 WARN 192.168.1.10 Memory usage above 85%
2026-09-11 10:03:05 INFO 192.168.1.15 User login successful
2026-09-11 10:03:10 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:03:15 INFO 192.168.1.50 User logout
2026-09-11 10:03:20 WARN 192.168.1.30 Disk usage above 80%
2026-09-11 10:03:25 INFO 192.168.1.10 User login successful
2026-09-11 10:03:30 ERROR 192.168.1.45 Authentication failed
2026-09-11 10:03:35 INFO 192.168.1.15 User login successful
2026-09-11 10:03:40 WARN 192.168.1.10 CPU usage above 90%
2026-09-11 10:03:45 ERROR 192.168.1.23 Database connection failed
2026-09-11 10:03:50 INFO 192.168.1.50 User login successful
2026-09-11 10:03:55 INFO 192.168.1.15 File uploaded successfully
2026-09-11 10:04:00 WARN 192.168.1.30 Memory usage above 85%
2026-09-11 10:04:05 ERROR 192.168.1.45 Authentication failed
2026-09-11 10:04:10 INFO 192.168.1.10 User login successful
EOF

if [ $? -eq 0 ]; then
  echo "Sample log data generated: '$LOG_FILE'"
else
  echo "Error: failed to generate sample log data." >&2
  exit 1
fi


RESULTS_FILE="results.txt"
ERROR_LOG="errors.log"

# ---------------------------------------------------------
# Step 2: Compute total number of log lines.
# wc -l counts lines; we redirect the summary into results.txt
# and send this command's own errors (if any) to errors.log
# instead of letting them print to the terminal.
# ---------------------------------------------------------
echo "===== Log Summary Report =====" > "$RESULTS_FILE" 2> "$ERROR_LOG"

TOTAL_LINES=$(wc -l < "$LOG_FILE" 2>> "$ERROR_LOG")
echo "Total log lines: $TOTAL_LINES" >> "$RESULTS_FILE"


# ---------------------------------------------------------
# Step 3: Count lines per log level.
# grep -c counts matching lines for each level separately.
# We append (>>) each result so we build up the report
# without overwriting what's already in results.txt.
# ---------------------------------------------------------
echo "" >> "$RESULTS_FILE"
echo "--- Log Level Counts ---" >> "$RESULTS_FILE"

INFO_COUNT=$(grep -c "INFO" "$LOG_FILE" 2>> "$ERROR_LOG")
WARN_COUNT=$(grep -c "WARN" "$LOG_FILE" 2>> "$ERROR_LOG")
ERROR_COUNT=$(grep -c "ERROR" "$LOG_FILE" 2>> "$ERROR_LOG")

echo "INFO:  $INFO_COUNT" >> "$RESULTS_FILE"
echo "WARN:  $WARN_COUNT" >> "$RESULTS_FILE"
echo "ERROR: $ERROR_COUNT" >> "$RESULTS_FILE"


# ---------------------------------------------------------
# Step 4: Find the top 3 most frequent IP addresses.
# awk '{print $4}' extracts just the 4th column (the IP field).
# sort groups identical IPs together so uniq can count them.
# uniq -c counts consecutive duplicates, sort -rn sorts those
# counts numerically in reverse (highest first), and head -3
# keeps only the top 3 results.
# ---------------------------------------------------------
echo "" >> "$RESULTS_FILE"
echo "--- Top 3 IP Addresses ---" >> "$RESULTS_FILE"

awk '{print $4}' "$LOG_FILE" 2>> "$ERROR_LOG" | sort | uniq -c | sort -rn | head -3 >> "$RESULTS_FILE"


# ---------------------------------------------------------
# Step 5: List all ERROR lines.
# grep alone (without -c) prints the matching lines themselves,
# giving a full view of every error that occurred.
# ---------------------------------------------------------
echo "" >> "$RESULTS_FILE"
echo "--- All ERROR Lines ---" >> "$RESULTS_FILE"

grep "ERROR" "$LOG_FILE" 2>> "$ERROR_LOG" >> "$RESULTS_FILE"
if [ $? -eq 0 ]; then
  echo "" >> "$RESULTS_FILE"
  echo "Report generated successfully: $RESULTS_FILE" 
else
  echo "Error: failed to extract ERROR lines from '$LOG_FILE'." >&2
  exit 1
fi

echo "All operations completed successfully."
exit 0
