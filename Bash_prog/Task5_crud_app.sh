
#!/usr/bin/env bash
# -----------------------------------------------------------------
# @title        Task5_crud_app.sh
# @author       Agnes Yeboah
# @index        5230160043
# @school       University of Skills Training and Entrepreneurial Development (USTED)
# @description  Menu-driven Todo list CRUD app storing data in a
#               CSV file, with backups before destructive changes.
# @date         2026-09-14
# -----------------------------------------------------------------
#
# Exit codes:
#   0 = normal exit
#   1 = missing required tool or unrecoverable setup error
# -----------------------------------------------------------------

usage() {
  echo "Usage: $0"
  echo "  This is an interactive menu-driven Todo list app."
  echo "  Run it with no arguments to start the menu."
  exit 1
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  usage
fi

DATA_FILE="data.txt"
BACKUP_FILE="data.txt.bak"

# ---------------------------------------------------------
# Ensure the data file exists before we start. If it doesn't,
# create it empty rather than erroring out on first run.
# ---------------------------------------------------------
if [ ! -f "$DATA_FILE" ]; then
  touch "$DATA_FILE"
  echo "No existing data file found - starting with an empty todo list."
fi


# ---------------------------------------------------------
# Generates the next numeric ID by finding the highest
# existing ID in the file and adding 1. If the file is
# empty, we start at 1.
# ---------------------------------------------------------
next_id() {
  local last_id
  last_id=$(cut -d',' -f1 "$DATA_FILE" | sort -n | tail -1)
  if [ -z "$last_id" ]; then
    echo 1
  else
    echo $((last_id + 1))
  fi
}

# ---------------------------------------------------------
# Add a new task. Validates that the description isn't empty
# before writing anything - an empty task makes no sense.
# ---------------------------------------------------------
add_task() {
  read -rp "Enter task description: " description
  if [ -z "$description" ]; then
    echo "Error: task description cannot be empty. Task not added." >&2
    return 1
  fi

# Reject descriptions that are purely numeric or symbols - a task
# should contain at least one letter to be a meaningful description.
if ! [[ "$description" =~ [a-zA-Z] ]]; then
  echo "Error: task description must contain at least one letter. Task not added." >&2
  return 1
fi
  read -rp "Enter due date (optional, press Enter to skip): " due_date

  local id
  id=$(next_id)

  echo "${id},${description},pending,${due_date}" >> "$DATA_FILE"
  if [ $? -eq 0 ]; then
    echo "Task added successfully with ID $id."
  else
    echo "Error: failed to save task." >&2
    return 1
  fi
}


# ---------------------------------------------------------
# Display all tasks in a readable table format. Handles the
# empty-list case gracefully instead of printing nothing
# with no explanation.
# ---------------------------------------------------------
view_tasks() {
  if [ ! -s "$DATA_FILE" ]; then
    echo "No tasks found. Your todo list is empty."
    return 0
  fi

  echo "-----------------------------------------------------------"
  printf "%-5s %-30s %-10s %-15s\n" "ID" "Description" "Status" "Due Date"
  echo "-----------------------------------------------------------"

  while IFS=',' read -r id description status due_date; do
    printf "%-5s %-30s %-10s %-15s\n" "$id" "$description" "$status" "$due_date"
  done < "$DATA_FILE"

  echo "-----------------------------------------------------------"
}


# ---------------------------------------------------------
# Search for tasks by matching text in the description.
# Uses grep for a simple case-insensitive substring search.
# ---------------------------------------------------------
search_task() {
  read -rp "Enter search term: " term
  if [ -z "$term" ]; then
    echo "Error: search term cannot be empty." >&2
    return 1
  fi

  local matches
  matches=$(grep -i "$term" "$DATA_FILE")

  if [ -z "$matches" ]; then
    echo "No matching tasks found for '$term'."
    return 0
  fi

  echo "-----------------------------------------------------------"
  printf "%-5s %-30s %-10s %-15s\n" "ID" "Description" "Status" "Due Date"
  echo "-----------------------------------------------------------"
  echo "$matches" | while IFS=',' read -r id description status due_date; do
    printf "%-5s %-30s %-10s %-15s\n" "$id" "$description" "$status" "$due_date"
  done
  echo "-----------------------------------------------------------"
}


# ---------------------------------------------------------
# Update an existing task's description, status, or due date.
# Backs up the data file first since this is a destructive
# change (it overwrites the existing line).
# ---------------------------------------------------------
update_task() {
  read -rp "Enter the ID of the task to update: " id
  if [ -z "$id" ]; then
    echo "Error: ID cannot be empty." >&2
    return 1
  fi

  if ! grep -q "^${id}," "$DATA_FILE"; then
    echo "No task found with ID $id."
    return 0
  fi

  cp "$DATA_FILE" "$BACKUP_FILE"
  if [ $? -ne 0 ]; then
    echo "Error: failed to back up data file before update." >&2
    return 1
  fi

  read -rp "Enter new description (press Enter to keep unchanged): " new_description
  read -rp "Enter new status (pending/done, press Enter to keep unchanged): " new_status
  read -rp "Enter new due date (press Enter to keep unchanged): " new_due_date

  local old_line
  old_line=$(grep "^${id}," "$DATA_FILE")

  IFS=',' read -r old_id old_description old_status old_due_date <<< "$old_line"
if [ -n "$new_description" ]; then
  if [[ "$new_description" =~ [a-zA-Z] ]]; then
    old_description="$new_description"
  else
    echo "Warning: new description must contain a letter - keeping original description." >&2
  fi
fi
  [ -n "$new_status" ] && old_status="$new_status"
  [ -n "$new_due_date" ] && old_due_date="$new_due_date"

  local updated_line="${old_id},${old_description},${old_status},${old_due_date}"

  sed -i "s|^${id},.*|${updated_line}|" "$DATA_FILE"
  if [ $? -eq 0 ]; then
    echo "Task $id updated successfully."
  else
    echo "Error: failed to update task $id." >&2
    return 1
  fi
}


# ---------------------------------------------------------
# Delete a task by ID, with confirmation before removing it,
# and a backup taken first since this is destructive.
# ---------------------------------------------------------
delete_task() {
  read -rp "Enter the ID of the task to delete: " id
  if [ -z "$id" ]; then
    echo "Error: ID cannot be empty." >&2
    return 1
  fi

  if ! grep -q "^${id}," "$DATA_FILE"; then
    echo "No task found with ID $id."
    return 0
  fi

  local task_line
  task_line=$(grep "^${id}," "$DATA_FILE")
  echo "Task found: $task_line"

  read -rp "Are you sure you want to delete this task? (y/n): " confirm
  if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Delete cancelled."
    return 0
  fi

  cp "$DATA_FILE" "$BACKUP_FILE"
  if [ $? -ne 0 ]; then
    echo "Error: failed to back up data file before delete." >&2
    return 1
  fi

  sed -i "/^${id},/d" "$DATA_FILE"
  if [ $? -eq 0 ]; then
    echo "Task $id deleted successfully."
  else
    echo "Error: failed to delete task $id." >&2
    return 1
  fi
}


# ---------------------------------------------------------
# Main menu loop. Keeps showing options until the user
# chooses Exit. case matches the user's numeric choice to
# the corresponding function.
# ---------------------------------------------------------
show_menu() {
  echo ""
  echo "===== Todo List Menu ====="
  echo "1) Add a task"
  echo "2) View all tasks"
  echo "3) Search tasks"
  echo "4) Update a task"
  echo "5) Delete a task"
  echo "6) Exit"
  echo "==========================="
}

while true; do
  show_menu
  read -rp "Choose an option (1-6): " choice

  case "$choice" in
    1) add_task ;;
    2) view_tasks ;;
    3) search_task ;;
    4) update_task ;;
    5) delete_task ;;
    6)
      echo "Goodbye!"
      exit 0
      ;;
    *)
      echo "Invalid option. Please choose a number between 1 and 6." >&2
      ;;
  esac
done
