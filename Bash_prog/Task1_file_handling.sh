#!/usr/bin/env bash
# -----------------------------------------------------------------
# @title        Task1_file_handling.sh
# @author       Agnes Yeboah
# @index        5230160043
# @school       University for Skills Training and Entrepreneurial Development (USTED)
# @description  Demonstrates basic file handling: create dir/file,
#               write, append, read, backup, and delete with checks.
# @date         2026-09-12
# -----------------------------------------------------------------

usage() {
  echo "Usage: $0 <target-directory>"
  echo "  <target-directory>  path to the directory to create/use"
  exit 1
}

# If no argument is given, or the user asked for help, show usage and stop.
# We check this first so nothing else runs with a missing/invalid argument.
if [[ "$1" == "-h" || "$1" == "--help" || -z "$1" ]]; then
  usage
fi

TARGET_DIR="$1"

# ---------------------------------------------------------
# Step 1: Create the target directory if it doesn't exist.
# -d checks whether it's already a directory. We only call
# mkdir if it isn't, so we can report created vs. already existed.
# ---------------------------------------------------------
if [ -d "$TARGET_DIR" ]; then
  echo "Directory '$TARGET_DIR' already exists."
else
  mkdir -p "$TARGET_DIR"
  if [ $? -eq 0 ]; then
    echo "Directory '$TARGET_DIR' created successfully."
  else
    echo "Error: failed to create directory '$TARGET_DIR'." >&2
    exit 1
  fi
fi

TARGET_FILE="$TARGET_DIR/sample.txt"

# ---------------------------------------------------------
# Step 2: Create the file and write initial content.
# Using > (overwrite) here is intentional: this is the first
# write, so we want a clean file rather than appending to
# leftovers from a previous run.
# ---------------------------------------------------------
echo "This is the initial content." > "$TARGET_FILE"
if [ $? -eq 0 ]; then
  echo "File '$TARGET_FILE' created and initial content written."
else
  echo "Error: failed to write to '$TARGET_FILE'." >&2
  exit 1
fi

# ---------------------------------------------------------
# Step 3: Append additional content.
# >> adds to the end of the file instead of overwriting it,
# which is what makes this "appending" rather than "writing".
# ---------------------------------------------------------
echo "This is appended content." >> "$TARGET_FILE"
if [ $? -eq 0 ]; then
  echo "Content appended to '$TARGET_FILE'."
else
  echo "Error: failed to append to '$TARGET_FILE'." >&2
  exit 1
fi

# ---------------------------------------------------------
# Step 4: Read and display the file's contents.
# This proves the write/append steps actually worked, and
# gives the user visible proof of the file's current state.
# ---------------------------------------------------------
echo "----- Contents of $TARGET_FILE -----"
cat "$TARGET_FILE"
if [ $? -eq 0 ]; then
  echo "----- End of file -----"
else
  echo "Error: failed to read '$TARGET_FILE'." >&2
  exit 1
fi

BACKUP_FILE="${TARGET_FILE}.bak"

# ---------------------------------------------------------
# Step 5: Back up the file before deleting the original.
# Keeping a .bak copy protects against accidental data loss
# in the delete step that follows.
# ---------------------------------------------------------
cp "$TARGET_FILE" "$BACKUP_FILE"
if [ $? -eq 0 ]; then
  echo "Backup created: '$BACKUP_FILE'."
else
  echo "Error: failed to create backup '$BACKUP_FILE'." >&2
  exit 1
fi

# ---------------------------------------------------------
# Step 6: Delete the original file, but only after confirming
# it actually exists. Checking first (-f) avoids a confusing
# "No such file" error from rm if something went wrong earlier.
# ---------------------------------------------------------
if [ -f "$TARGET_FILE" ]; then
  echo "Confirmed: '$TARGET_FILE' exists. Proceeding to delete the original (backup already saved)."
  rm "$TARGET_FILE"
  if [ $? -eq 0 ]; then
    echo "Original file '$TARGET_FILE' deleted successfully."
  else
    echo "Error: failed to delete '$TARGET_FILE'." >&2
    exit 1
  fi
else
  echo "Error: '$TARGET_FILE' does not exist, nothing to delete." >&2
  exit 1
fi

echo "All operations completed successfully."
exit 0
