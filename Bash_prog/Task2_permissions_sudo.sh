#!/usr/bin/env bash
# -----------------------------------------------------------------
# @title        Task2_permissions_sudo.sh
# @author       Agnes Yeboah
# @index        5230160043
# @school       University of Skills Training and Entrepreneurial Development (USTED)
# @description  Reports and modifies file permissions (symbolic and
#               numeric), and demonstrates ownership change with sudo.
# @date         2026-09-13
# -----------------------------------------------------------------

usage() {
  echo "Usage: $0 <file-path>"
  echo "  <file-path>  path to the file to inspect/modify"
  exit 1
}

# If no argument given, or -h/--help requested, show usage
if [[ "$1" == "-h" || "$1" == "--help" || -z "$1" ]]; then
  usage
fi

FILE_PATH="$1"

# Validate that the file actually exists before doing anything else.
# There's no point reporting permissions on something that isn't there.
if [ ! -f "$FILE_PATH" ]; then
  echo "Error: '$FILE_PATH' does not exist or is not a regular file." >&2
  exit 1
fi


# ---------------------------------------------------------
# Step 1: Report current permissions, both symbolic and numeric.
# stat gives us both formats directly without needing to
# manually parse the output of ls -l.
# ---------------------------------------------------------
SYMBOLIC_PERMS=$(stat -c "%A" "$FILE_PATH")
NUMERIC_PERMS=$(stat -c "%a" "$FILE_PATH")

if [ $? -eq 0 ]; then
  echo "Current permissions of '$FILE_PATH':"
  echo "  Symbolic: $SYMBOLIC_PERMS"
  echo "  Numeric:  $NUMERIC_PERMS"
else
  echo "Error: failed to read permissions of '$FILE_PATH'." >&2
  exit 1
fi


# ---------------------------------------------------------
# Step 2: Change permissions using numeric syntax.
# chmod 644 means: owner can read/write, group and others
# can only read. This is a common "safe default" for files.
# ---------------------------------------------------------
chmod 644 "$FILE_PATH"
if [ $? -eq 0 ]; then
  echo "Applied numeric permission change: chmod 644 '$FILE_PATH'"
else
  echo "Error: failed to apply chmod 644 to '$FILE_PATH'." >&2
  exit 1
fi


# ---------------------------------------------------------
# Step 3: Change permissions using symbolic syntax.
# u+x adds execute permission for the file's owner (u = user/owner),
# without touching group/other permissions like a numeric chmod would.
# ---------------------------------------------------------
chmod u+x "$FILE_PATH"
if [ $? -eq 0 ]; then
  echo "Applied symbolic permission change: chmod u+x '$FILE_PATH'"
else
  echo "Error: failed to apply chmod u+x to '$FILE_PATH'." >&2
  exit 1
fi


# ---------------------------------------------------------
# Step 4: Attempt to change ownership, but only if running as root.
# id -u prints the current user's numeric ID; root is always 0.
# chown requires root privileges on most systems, so we check
# first instead of letting the command fail with a scary error.
# ---------------------------------------------------------
CURRENT_UID=$(id -u)

if [ "$CURRENT_UID" -eq 0 ]; then
  echo "Running as root. Attempting to change ownership to root:root..."
  chown root:root "$FILE_PATH"
  if [ $? -eq 0 ]; then
    echo "Ownership changed successfully."
  else
    echo "Error: failed to change ownership of '$FILE_PATH'." >&2
    exit 1
  fi
else
  echo "Skipped ownership change: this step requires root privileges (run with sudo to attempt it)."
fi


# ---------------------------------------------------------
# Step 5: Report permissions again after all changes, so the
# before/after difference is clearly visible to the user.
# ---------------------------------------------------------
SYMBOLIC_PERMS_AFTER=$(stat -c "%A" "$FILE_PATH")
NUMERIC_PERMS_AFTER=$(stat -c "%a" "$FILE_PATH")

if [ $? -eq 0 ]; then
  echo "Permissions of '$FILE_PATH' after changes:"
  echo "  Symbolic: $SYMBOLIC_PERMS_AFTER"
  echo "  Numeric:  $NUMERIC_PERMS_AFTER"
else
  echo "Error: failed to read final permissions of '$FILE_PATH'." >&2
  exit 1
fi

echo "All operations completed successfully."
exit 0
